{
  lib,
  inputs,
  ...
}: let
  inherit (builtins) filter map toString elem;
  inherit (lib.filesystem) listFilesRecursive;
  inherit (lib.strings) hasSuffix;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) str int;

  # `mkModuleTree` is used to recursively import all Nix file in a given directory, assuming the
  # given directory to be the module root, where rest of the modules are to be imported. This
  # retains a sense of explicitness in the module tree, and allows for a more organized module
  # imports, discarding the vague `default.nix` name for directories that are *modules*.
  mkModuleTree = {
    path,
    ignoredPaths ? [./default.nix],
  }:
    filter (hasSuffix ".nix") (
      map toString (
        # List all files in the given path, and filter out paths that are in
        # the ignoredPaths list
        filter (path: !elem path ignoredPaths) (listFilesRecursive path)
      )
    );

  # A variant of mkModuleTree that provides more granular control over the files that are imported.
  # While `mkModuleTree` imports all Nix files in the given directory, `mkModuleTree'` will look
  # for a specific
  mkModuleTree' = {
    path,
    ignoredPaths ? [],
  }: (
    # Two conditions fill satisfy filter here:
    #  - The path should end with a module.nix, indicating
    #   that it is in fact a module file.
    #  - The path is not contained in the ignoredPaths list.
    # If we cannot satisfy both of the conditions, then the path will be ignored
    filter (hasSuffix "module.nix") (
      map toString (
        filter (path: !elem path ignoredPaths) (listFilesRecursive path)
      )
    )
  );

  # The `mkService` function takes a few arguments to generate
  # a module for a service without repeating the same options
  # over and over: every online service needs a host and a port.
  # I can't exactly tell you why, but if I am to be honest
  # this is actually a horrendous abstraction
  mkService = {
    name,
    type ? "", # type being an empty string means it can be skipped, omitted
    host ? "127.0.0.1", # default to listening only on localhost
    port ? 0, # default port should be a stub
    extraOptions ? {}, # used to define additional modules
  }: {
    enable = mkEnableOption "${name} ${type} service";
    settings =
      {
        host = mkOption {
          type = str;
          default = host;
          description = "The host ${name} will listen on";
        };

        port = mkOption {
          type = int;
          default = port;
          description = "The port ${name} will listen on";
        };
      }
      // extraOptions;
  };
  # <nixpkgs>/lib/modules.nix priorities:
  # mkOptionDefault = 1500: priority of option defaults
  # mkDefault = 1000: used in config sections of non-user modules to set a default
  # mkImageMediaOverride = 60:
  # mkForce = 50:
  # mkVMOverride = 10: used by ‘nixos-rebuild build-vm’

  /*
  mkOverride function with a preset priority set for all of the
  home-manager modules.

  *Type*: `mkOverrideAtModuleLevel :: AttrSet a -> { _type :: String; priority :: Int; content :: AttrSet a; }`
  */
  mkOverrideAtHmModuleLevel = mkOverride 700;

  /*
  mkOverride function with a preset priority set for all of the
  home-manager profile modules.

  *Type*: `mkOverrideAtHmProfileLevel :: AttrSet a -> { _type :: String; priority :: Int; content :: AttrSet a; }`
  */
  mkOverrideAtHmProfileLevel = mkOverride 600;

  /*
  mkOverride function with a preset priority set for all of the nixos
  modules.

  *Type*: `mkOverrideAtModuleLevel :: AttrSet a -> { _type :: String; priority :: Int; content :: AttrSet a; }`
  */
  mkOverrideAtModuleLevel = mkOverride 500;

  /*
  mkOverride function with a preset priority set for all of the nixos
  profiles, that is, modules that preconfigure other modules.

  *Type*: `mkOverrideAtProfileLevel :: AttrSet a -> { _type :: String; priority :: Int; content :: AttrSet a; }`
  */
  mkOverrideAtProfileLevel = mkOverride 400;

  /*
  Recursively checks the presence of a nixos/home-manager module and whether
  its enabled.

  One might ask why not `?` or `hasAttr` instead?
  1. The `?` operator is indeed able to handle nested attributes, however, I've
     had some errors while linting and running the `check` command during
     development, which seems to be due to the inline direct syntax with a
     potentially nonexisting attributes.
  2. The `hasAttr` takes a string identifier instead, which is more safe, however,
      it doesn't support nested attributes.

  The solution is then to construct a recursive traverse over the identifier
  using the `hasAttr` function.

  *Type*: `isModuleLoadedAndEnabled :: AttrSet -> String -> Bool`
  */
  isModuleLoadedAndEnabled = cfg: identifier: let
    aux = acc: parts: let
      elem = head parts;
      rest = tail parts;
    in
      if length rest == 0
      then (hasAttr elem acc) && (hasAttr "enable" acc.${elem}) && acc.${elem}.enable
      else (hasAttr elem acc) && (aux acc.${elem} rest);
  in
    aux cfg (splitString "." identifier);

  /*
  Recursively read a directory and apply a provided function to every `.nix`
  file. Returns an attrset that reflects the filenames and directory
  structure of the root.

  Notes:

   1. Files and directories starting with the `_` or `.git` prefix will be completely
      ignored.

   2. If a directory with a `myDir/default.nix` file will be encountered,
      the function will be applied to the `myDir/default.nix` file
      instead of recursively loading `myDir` and applying it to every file.

  *Type*: `mapModules :: Path -> (Path -> AttrSet a) -> { name :: String; value :: AttrSet a; }`

  Example:
  ```nix title="Example" linenums="1"
  mapModules ./modules import
    => { hardware = { moduleA = { ... }; }; system = { moduleB = { ... }; }; }

  mapModules ./hosts (host: mkHostCustomFunction myArg host)
    => { hostA = { ... }; hostB = { ... }; }
  ```
  */
  mapModules =
    # (Path) Root directory on which should the recursive mapping be applied
    dir:
    # (Path -> AttrSet a) Function that transforms node paths to their custom attrsets
    fn:
      mapFilterAttrs (n: v: v != null && !(hasPrefix "_" n) && !(hasPrefix ".git" n)) (
        n: v: let
          path = "${toString dir}/${n}";
        in
          if v == "directory" && pathExists "${path}/default.nix"
          then nameValuePair n (fn path)
          else if v == "directory"
          then nameValuePair n (mapModules path fn)
          else if v == "regular" && n != "default.nix" && hasSuffix ".nix" n
          then nameValuePair (removeSuffix ".nix" n) (fn path)
          else nameValuePair "" null
      ) (readDir dir);

  /*
  Custom nixpkgs constructor. Its purpose is to import provided nixpkgs
  while setting the target platform and all over the needed overlays.

  *Type*: `mkNixpkgs :: AttrSet -> String -> [(AttrSet -> AttrSet -> AttrSet)] -> Attrset`

  Example:
  ```nix title="Example" linenums="1"
  mkNixpkgs inputs.nixpkgs "x86_64-linux" []
    => { ... }

  mkNixpkgs inputs.nixpkgs "aarch64-linux" [ (final: prev: {
    customPkgs = inputs.customPkgs { pkgs = final; };
  }) ]
    => { ... }
  ```
  */
  mkNixpkgs =
    # (AttrSet) TODO (this is probably not an actual attrset?)
    pkgs:
    # (String) System string identifier (eg: "x86_64-linux", "aarch64-linux", "aarch64-darwin")
    system:
    # ([AttrSet -> AttrSet -> AttrSet]) Extra overlays that should be applied to the created pkgs
    extraOverlays:
      import pkgs {
        inherit system;
        config.allowUnfree = true;
        hostPlatform = system;
        overlays = let
          pkgsOverlay = _final: _prev: {tensorfiles = inputs.self.packages.${system};};
        in
          [pkgsOverlay] ++ extraOverlays;
      };

  /*
  Returns a dummy derivation with a given name as and a platform
  specific builder. Useful when constructing certain defaults or general
  debugging. The resulting derivation can be compiled without errors, but
  obviously doesn't produce any nontrivial output.

  *Type*: `mkDummyDerivation :: String -> String -> AttrSet a -> Package a`

  Example:
  ```nix title="Example" linenums="1"
  mkDummyDerivation "example-pkg" "aarch64-linux" {}
   => derivation

  mkDummyDerivation "example-pkg2" "x86_64-linux" { meta.license = lib.licenses.gpl20; }
   => derivation
  ```
  */
  mkDummyDerivation =
    # (String) Name of the dummy derivation
    name:
    # (String) System architecture string. This is going to be used for choosing the target derivation builder
    system:
    # (AttrSet a) An attrset with possibly any additional values that are going to be passed to the mkDerivation call
    extraArgs: let
      systemPkgs = mkNixpkgs inputs.nixpkgs system [];
      args =
        rec {
          inherit name;
          version = "not-for-build";

          # In case something tries to actually evaluate this, we have to provide
          #
          # 1. Declaratively some source?
          # 2. Minimally something to do during the installPhase
          src = ./.;
          dontBuild = true;
          installPhase = ''
            echo "DUMMY PACKAGE for ${name}" && mkdir -p $out
          '';

          meta = {
            homepage = "https://github.com/czichy/tensorfiles";
            description = "Dummy package used for ${name} -- not for build";
            license = licenses.mit;
            platforms = [system];
            maintainers = [];
          };
        }
        // extraArgs;
    in
      systemPkgs.stdenv.mkDerivation args;
in rec {
  inherit mkService mkModuleTree mkModuleTree';
}

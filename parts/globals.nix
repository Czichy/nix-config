{
  inputs,
  self,
  ...
}: {
  flake = {
    config,
    # lib,
    ...
  }: {
    globals = let
      globalsSystem = self.lib.evalModules {
        prefix = ["globals"];
        specialArgs = {
          # inherit (inputs.self.pkgs.x86_64-linux) lib;
          inherit (self) lib;
          inherit inputs;
        };
        modules = [
          ../modules/options/globals/module.nix
          ../globals.nix
          ({lib, ...}: {
            globals = lib.mkMerge (
              lib.concatLists (lib.flip lib.mapAttrsToList config.nodes (
                name: cfg:
                  builtins.addErrorContext "while aggregating globals from nixosConfigurations.${name} into flake-level globals:"
                  cfg.config._globalsDefs
              ))
            );
          })
        ];
      };
    in {
      # Make sure the keys of this attrset are trivially evaluatable to avoid infinite recursion,
      # therefore we inherit relevant attributes from the config.
      inherit
        (globalsSystem.config.globals)
        domains
        # hetzner
        
        # kanidm
        
        macs
        mail
        monitoring
        # myuser
        
        net
        # root
        
        services
        ;
    };
  };
}

{inputs, ...}: {
  flake = {
    config,
    lib,
    ...
  }: {
    globals = let
      globalsSystem = lib.evalModules {
        prefix = ["globals"];
        specialArgs = {
          inherit (inputs.self.pkgs.x86_64-linux) lib;
          inherit inputs;
        };
        modules = [
          ../modules/globals.nix
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
# {
#   config,
#   lib,
#   self,
#   inputs,
#   ...
# }: let
#   localFlake = self;
# in {
#   flake = {
#     # config,
#     # lib,
#     pkgs,
#     system,
#     ...
#   }: {
#     globals = let
#       globalsSystem = lib.evalModules {
#         prefix = ["globals"];
#         specialArgs = {
#           inherit lib;
#           # inherit (inputs.self.pkgs.x86_64-linux) lib;
#           inherit config;
#         };
#         modules = [
#           ./globals.nix
#           ../globals.nix
#           # ({
#           #   lib,
#           #   config,
#           #   ...
#           # }: {
#           #   globals = lib.mkMerge (
#           #     lib.concatLists (lib.flip lib.mapAttrsToList config.nodes (
#           #       name: cfg:
#           #         builtins.addErrorContext "while aggregating globals from nixosConfigurations.${name} into flake-level globals:"
#           #         cfg.config._globalsDefs
#           #     ))
#           #   );
#           # })
#         ];
#       };
#     in {
#       # Make sure the keys of this attrset are trivially evaluatable to avoid infinite recursion,
#       # therefore we inherit relevant attributes from the config.
#       inherit (globalsSystem.config.globals) net services monitoring;
#     };
#   };
# }


{
  config,
  lib,
  pkgs,
  inputs,
  globals,
  secretsPath,
  ...
}: let
  inherit (lib.lists) concatLists flatten singleton;
  inherit (lib) mkModuleTree';
  ## flake inputs ##
  # hw = inputs.nixos-hardware.nixosModules; # hardware compat for pi4 and other quirky devices
  agenix = inputs.agenix.nixosModules.default; # secret encryption via age
  topology = inputs.nix-topology.nixosModules.default; # infrastructure and network diagrams directly from your NixOS configurations

  # Specify root path for the modules. The concept is similar to modulesPath
  # that is found in nixpkgs, and is defined in case the modulePath changes
  # depth (i.e modules becomes nixos/modules).
  modulePath = ../../modules;

  coreModules = modulePath + /core; # the path where common modules reside
  extraModules = modulePath + /extra; # the path where extra modules reside
  options = modulePath + /options; # the module that provides the options for my system configuration

  ## common modules ##
  # The opinionated defaults for all systems, generally things I want on all hosts
  # regardless of their role in the general ecosystem. E.g. both servers and workstations
  # will share the defaults below.
  common = coreModules + /common; # the self-proclaimed sane defaults for all my systems
  profiles = coreModules + /profiles; # force defaults based on selected profile

  microvm = coreModules + /roles/microvm; # for devices that are of the microvm types

  # extra modules - optional but likely critical to a successful build
  sharedModules = extraModules + /shared; # the path where shared modules reside

  # a list of shared modules that ALL systems need
  shared = [
    sharedModules # consume my flake's own nixosModules
    agenix # age encryption for secrets
    topology # infrastructure and network diagrams directly from your NixOS configurations
    ../../globals.nix
  ];
  # mkModulesFor generates a list of modules to be imported by any host with
  # a given hostname. Do note that this needs to be called *in* the nixosSystem
  # set, since it generates a *module list*, which is also expected by system
  # builders.
  mkModulesFor = guestName: {
    moduleTrees ? [options common profiles],
    roles ? [],
    extraModules ? [],
  } @ args:
    flatten (
      concatLists [
        # Derive host specific module path from the first argument of the
        # function. Should be a string, obviously.
        (singleton ./guests/${guestName}.nix)

        # Recursively import all module trees (i.e. directories with a `module.nix`)
        # for given moduleTree directories, and in addition, roles.
        (map (path: mkModuleTree' {inherit path;}) (concatLists [moduleTrees roles]))

        # And append any additional lists that don't don't conform to the moduleTree
        # API, but still need to be imported somewhat commonly.
        args.extraModules
      ]
    );

  macAddress_enp4s0 = "60:be:b4:19:a8:4f";
in {
  config.modules.system.services.microvm = {
    enable = true;
    guests = let
      mkGuest = guestName: {enableStorageDataset ? false, ...}: {
        autostart = true;
        # temporary state that is wiped on reboot
        # zfs."/state" = {
        #   pool = "rpool";
        #   dataset = "rpool/encrypted/vms/${guestName}";
        # };
        # persistent state
        # zfs."/persist" = {
        #   pool = "rpool";
        #   dataset = "rpool/encrypted/safe/vms/${guestName}";
        # };
        modules =
          mkModulesFor "${guestName}"
          {
            roles = [microvm];
            extraModules = [shared];
          };
        # modules = [
        # ../config/default.nix
        # ../../../modules/core/deterministic_ids.nix
        # ../../../globals/globals.nix
        # ./guests/${guestName}.nix
        # ++ [shared]
        #   {
        #     #node.secretsDir = ./secrets/${guestName};
        #     networking.nftables.firewall = {
        #       zones.untrusted.interfaces = [
        #         config.tensorfiles.services.microvm.guests.${guestName}.networking.mainLinkName
        #       ];
        #     };
        #   }
        # ];
        # ++ (inputs.nixpkgs.lib.attrValues config.flake.nixosModules);
      };
      mkMicrovm = guestName: opts: {
        ${guestName} =
          mkGuest guestName opts
          // {
            microvm = {
              system = "x86_64-linux";
              macvtap = "enp4s0";
              # macvtap = "lan";
              # baseMac = macAddress_enp4s0; # TODO move to config
            };
            networking.address = globals.net.vlan40.hosts."HL-1-MRZ-SBC-01-${guestName}".cidrv4;
            networking.gateway = globals.net.vlan40.hosts.opnsense.ipv4;
            extraSpecialArgs = {
              inherit secretsPath;
              inherit globals;
              inherit lib;
              inherit inputs;
            };
          };
      };
    in (
      {}
      // mkMicrovm "adguardhome" {enableStorageDataset = true;}
      # // mkMicrovm "vaultwarden" {enableStorageDataset = true;}
      # // mkMicrovm "unifi" {enableStorageDataset = true;}
    );
  };
}

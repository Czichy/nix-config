{inputs, ...}: {
  imports = [
    inputs.disko.nixosModules.disko
    ../../modules/options/globals/module.nix
    ./disko.nix

    ./modules

    ./networking.nix
    ./nftables.nix
    ./guests.nix
  ];

  config = {
    topology.self.icon = "devices.desktop";
    networking.domain = "czichy.dev";

    system.stateVersion = "24.05";
  };
}

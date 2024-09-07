{inputs, ...}: {
  imports = [
    inputs.disko.nixosModules.disko
    ./disko.nix

    ./modules

    ./networking.nix
    ./nftables.nix
  ];

  config = {
    topology.self.icon = "devices.desktop";
    networking.domain = "czichy.dev";

    system.stateVersion = "24.05";
    # services.smartd.enable = mkForce false;

    # boot = {
    #   growPartition = !config.boot.initrd.systemd.enable;
    #   loader.grub = {
    #     enable = true;
    #     useOSProber = mkForce false;
    #     efiSupport = mkForce false;
    #     enableCryptodisk = false;
    #     theme = null;
    #     backgroundColor = null;
    #     splashImage = null;
    #     device = mkForce "/dev/disk/by-label/nixos";
    #     forceInstall = true;
    #   };
    # };
  };
}

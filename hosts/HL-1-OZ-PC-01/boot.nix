{
  config,
  lib,
  pkgs,
  ...
}: {
  boot = lib.mkIf (!config.boot.isContainer) {
    initrd.systemd = {
      enable = true;
      #emergencyAccess = config.secrets.secrets.global.users.root.passwordHash;
      extraBin.ip = "${pkgs.iproute}/bin/ip";
      extraBin.cryptsetup = "${pkgs.cryptsetup}/bin/cryptsetup";
      users.root.shell = "${pkgs.bashInteractive}/bin/bash";
      storePaths = ["${pkgs.bashInteractive}/bin/bash"];
    };

    initrd.availableKernelModules = [
      "xhci_pci"
      "nvme"
      "r8169"
      "usb_storage"
      "usbhid"
      "sd_mod"
      "rtsx_pci_sdmmc"
      "ahci"
      "uas"
      "tpm_crb"
    ];
    supportedFilesystems = ["ntfs"];
    kernelModules = [
      "kvm-amd"
      "amdgpu"
      "i2c-dev"
    ];
    kernelParams = [
      # NOTE: Add "rd.systemd.unit=rescue.target" to debug initrd
      "log_buf_len=16M" # must be {power of two}[KMG]
      # "rd.luks.options=timeout=0"
      "rootflags=x-systemd.device-timeout=0"
      # NOTE: Add "rd.systemd.unit=rescue.target" to debug initrd
      #"rd.systemd.unit=rescue.target"
    ];

    tmp.useTmpfs = true;

    # # BTRFS stuff
    # # Scrub btrfs to protect data integrity
    # services.btrfs.autoScrub.enable = true;

    # services.btrbk.instances."btrbk" = {
    #   onCalendar = "*:0/10";
    #   settings = {
    #     snapshot_preserve = "14d";
    #     snapshot_preserve_min = "2d";

    #     target_preserve_min = "no";
    #     target_preserve = "no";

    #     preserve_day_of_week = "monday";
    #     timestamp_format = "long-iso";
    #     snapshot_create = "onchange";

    #     volume."/" = {
    #       subvolume = {
    #         "home" = {
    #           snapshot_dir = "/.snapshots/data/home";
    #         };
    #       };
    #     };
    #   };
    # };

    # # ensure snapshots_dir exists
    # systemd.tmpfiles.rules = ["d /.snapshots/data/home 0755 root root - -"];
    loader = {
      timeout = lib.mkDefault 2;
      grub.enable = false;
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
    };
    #binfmt.emulatedSystems = [ "aarch64-linux" ];
    kernelPackages = pkgs.linuxPackages_latest;
  };
}

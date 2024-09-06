{
  config,
  globals,
  ...
}:
#let
#macAddress_enp39s0 = "2c:f0:5d:9f:10:37";
# in
{
  #  we don't want the kernel setting up interfaces magically for us
  boot.extraModprobeConfig = "options bonding max_bonds=0";
  networking = {
    useDHCP = false;
    useNetworkd = true;
  };

  services.resolved = {
    enable = true;
    # man I whish dnssec would be viable to use
    dnssec = "false";
    llmnr = "false";
    extraConfig = ''
      Domains=~.
      MulticastDNS=true
    '';
  };

  # |----------------------------------------------------------------------| #
  systemd.network.netdevs."10-trust" = {
    netdevConfig = {
      Kind = "vlan";
      Name = "trust";
      Description = "Trust VLAN10 OZ";
    };
    vlanConfig.Id = 10;
  };

  systemd.network.netdevs."10-servers" = {
    netdevConfig = {
      Kind = "vlan";
      Name = "servers";
      Description = "Servers VLAN40 RZ";
    };
    vlanConfig.Id = 40;
  };

  systemd.network.netdevs."10-mgmt" = {
    netdevConfig = {
      Kind = "vlan";
      Name = "mgmt";
      Description = "Management VLAN100 MRZ";
    };
    vlanConfig.Id = 100;
  };
  # |----------------------------------------------------------------------| #

  systemd.network = {
    enable = true;

    wait-online = {
      enable = false;
      anyInterface = true;
      extraArgs = ["--ipv4"];
    };

    # https://wiki.archlinux.org/title/Systemd-networkd
    networks = {
      # leave the kernel dummy devies unmanagaed
      "10-dummy" = {
        matchConfig.Name = "dummy*";
        networkConfig = {};
        # linkConfig.ActivationPolicy = "always-down";
        linkConfig.Unmanaged = "yes";
      };

      # let me configure tailscale manually
      "20-tailscale-ignore" = {
        matchConfig.Name = "tailscale*";
        linkConfig = {
          Unmanaged = "yes";
          RequiredForOnline = false;
        };
      };

      # wired interfaces e.g. ethernet
      "30-network-defaults-wired" = {
        # matchConfig.Name = "en* | eth* | usb*";
        matchConfig.Type = "ether";
        networkConfig = {
          DHCP = "yes";
          IPv6AcceptRA = true;
          IPForward = "yes";
          IPMasquerade = "no";
        };
        # tag vlan on this link
        vlan = [
          "trust"
          "servers"
          "mgmt"
        ];

        dhcpV4Config = {
          ClientIdentifier = "duid"; # "mac"
          Use6RD = "yes";
          RouteMetric = 512; # should be higher than the wireless RouteMetric so that wireless is preferred
          UseDNS = false;
          DUIDType = "link-layer";
        };

        dhcpV6Config = {
          RouteMetric = 512;
          PrefixDelegationHint = "::64";
          UseDNS = false;
          DUIDType = "link-layer";
        };
      };

      "30-trust" = {
        matchConfig.Name = "trust";
        matchConfig.Type = "vlan";
        address = [globals.net.vlan10.hosts.HL-1-OZ-PC-01.cidrv4];
        gateway = [globals.net.vlan10.hosts.opnsense.ipv4];
        networkConfig = {
          ConfigureWithoutCarrier = true;
          DHCP = "no";
        };
        linkConfig.RequiredForOnline = "routable";
      };

      "30-servers" = {
        matchConfig.Name = "servers";
        matchConfig.Type = "vlan";
        # address = ["10.15.40.62/24"];
        # gateway = ["10.15.40.99"];
        networkConfig = {
          ConfigureWithoutCarrier = true;
          DHCP = "yes";
        };
        linkConfig.RequiredForOnline = "routable";
      };

      "30-mgmt" = {
        matchConfig.Name = "mgmt";
        matchConfig.Type = "vlan";
        bridgeConfig = {};
        # address = ["10.15.100.62/24"];
        # gateway = ["10.15.100.99"];
        networkConfig = {
          ConfigureWithoutCarrier = true;
          DHCP = "yes";
        };
        linkConfig.RequiredForOnline = "routable";
      };
      # # wireless interfaces e.g. network cards
      # "30-network-defaults-wireless" = {
      #   # matchConfig.Name = "wl*";
      #   matchConfig.Type = "wlan";
      #   networkConfig = {
      #     DHCP = "yes";
      #     IPv6AcceptRA = true;
      #     IPForward = "yes";
      #     IPMasquerade = "no";
      #   };

      #   dhcpV4Config = {
      #     ClientIdentifier = "mac";
      #     RouteMetric = 216;
      #     UseDNS = true;
      #     DUIDType = "link-layer";
      #     Use6RD = "yes";
      #   };

      #   dhcpV6Config = {
      #     RouteMetric = 216;
      #     UseDNS = true;
      #     DUIDType = "link-layer";
      #     PrefixDelegationHint = "::64";
      #   };
      # };
    };
  };
}

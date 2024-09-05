{
  config,
  globals,
  lib,
  pkgs,
  ...
}: let
  adguardhomeDomain = "adguardhome.czichy.com";
  # adguardhomeDomain = "adguardhome.${config.repo.secrets.global.domains.me}";
  filter-dir = "https://adguardteam.github.io/HostlistsRegistry/assets";
in {
  # wireguard.proxy-sentinel = {
  #   client.via = "sentinel";
  #   firewallRuleForNode.sentinel.allowedTCPPorts = [config.services.adguardhome.port];
  # };
  globals.services.adguardhome.domain = adguardhomeDomain;
  # globals.monitoring.dns.adguardhome = {
  #   server = globals.net.home-lan.hosts.ward-adguardhome.ipv4;
  #   domain = ".";
  #   network = "home-lan";
  # };
  # systemd.network.networks."20-tap" = {
  #   matchConfig.Type = "ether";
  #   matchConfig.MACAddress = "60:be:b4:19:a8:4f";
  #   networkConfig = {
  #     Address = ["10.15.1.40/24"];
  #     Gateway = "10.15.1.99";
  #     DNS = ["8.8.8.8"];
  #     IPv6AcceptRA = true;
  #     DHCP = "yes";
  #   };
  # };
  # nodes.sentinel = {
  #   services.nginx = {
  #     upstreams.adguardhome = {
  #       # servers."${config.wireguard.proxy-sentinel.ipv4}:${toString config.services.adguardhome.port}" = {};
  #       extraConfig = ''
  #         zone adguardhome 64k;
  #         keepalive 2;
  #       '';
  #       monitoring = {
  #         enable = true;
  #         expectedBodyRegex = "AdGuard Home";
  #       };
  #     };
  #     virtualHosts.${adguardhomeDomain} = {
  #       forceSSL = true;
  #       useACMEWildcardHost = true;
  #       oauth2.enable = true;
  #       oauth2.allowedGroups = ["access_adguardhome"];
  #       locations."/" = {
  #         proxyPass = "http://adguardhome";
  #         proxyWebsockets = true;
  #       };
  #     };
  #   };
  # };

  # environment.persistence."/persist".directories = [
  #   {
  #     directory = "/var/lib/private/AdGuardHome";
  #     mode = "0700";
  #   }
  # ];

  networking.firewall = {
    allowedTCPPorts = [53 80 443 3000];
    allowedUDPPorts = [53];
  };

  # topology.self.services.adguardhome.info = "https://" + adguardhomeDomain;
  services.adguardhome = {
    enable = true;
    mutableSettings = false;
    host = "0.0.0.0";
    port = 3000;
    settings = {
      dns = {
        # port = 53;
        # allowed_clients = [
        # ];
        #trusted_proxies = [];
        ratelimit = 300;
        bind_hosts = ["::"];
        upstream_dns = [
          "https://dns.cloudflare.com/dns-query"
          "https://dns.google/dns-query"
          "https://doh.mullvad.net/dns-query"
        ];
        bootstrap_dns = [
          "1.1.1.1"
          # FIXME: enable ipv6 "2606:4700:4700::1111"
          "8.8.8.8"
          # FIXME: enable ipv6 "2001:4860:4860::8844"
        ];
        dhcp.enabled = false;
      };
      filtering.rewrites =
        [
          # Undo the /etc/hosts entry so we don't answer with the internal
          # wireguard address for influxdb
          {
            # inherit (globals.services.influxdb) domain;
            # answer = config.repo.secrets.global.domains.me;
          }
        ]
        # Use the local mirror-proxy for some services (not necessary, just for speed)
        ++ map (domain: {
          inherit domain;
          answer = globals.net.home-lan.hosts.ward-web-proxy.ipv4;
        }) [
          # FIXME: dont hardcode, filter global service domains by internal state
          # globals.services.grafana.domain
          # globals.services.immich.domain
          # globals.services.influxdb.domain
          # "home.${config.repo.secrets.global.domains.me}"
          # "fritzbox.${config.repo.secrets.global.domains.me}"
        ];
      filters = [
        {
          name = "AdGuard DNS filter";
          url = "https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt";
          enabled = true;
        }
        {
          name = "AdAway Default Blocklist";
          url = "https://adaway.org/hosts.txt";
          enabled = true;
        }
        {
          name = "OISD (Big)";
          url = "https://big.oisd.nl";
          enabled = true;
        }
      ];
    };
  };

  # systemd.services.adguardhome = {
  #   preStart = lib.mkAfter ''
  #     INTERFACE_ADDR=$(${pkgs.iproute2}/bin/ip -family inet -brief addr show lan | grep -o "[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+") \
  #       ${lib.getExe pkgs.yq-go} -i '.dns.bind_hosts = [strenv(INTERFACE_ADDR)]' \
  #       "$STATE_DIRECTORY/AdGuardHome.yaml"
  #   '';
  #   serviceConfig.RestartSec = lib.mkForce "60"; # Retry every minute
  # };

  systemd.network.enable = true;
  networking.hostName = "HL-1-MRZ-SBC-01-adguardhome";
  # systemd.network.networks."99-v-lan" = {
  #   matchConfig.Type = "ether";
  #   DHCP = "yes";
  #   networkConfig = {
  #     Address = [globals.net.vlan40.hosts.HL-1-MRZ-SBC-01-adguardhome.ipv4];
  #     # Gateway = [globals.net.vlan40.cidrv4];
  #     # DNS = nameservers;
  #   };
  # };
  system.stateVersion = "24.05";
}

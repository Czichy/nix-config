{
  config,
  lib,
  self,
  pkgs,
  ...
}:
with lib; let
  domain = "cloud.notashelf.dev";

  dev = config.modules.device;
  cfg = config.modules.system.services;
  acceptedTypes = ["server" "hybrid"];
in {
  config = mkIf ((builtins.elem dev.type acceptedTypes) && cfg.nextcloud.enable) {
    age.secrets.nextcloud-auth = {
      file = "${self}/secrets/nextcloud-secret.age";
      owner = "nextcloud";
    };

    modules.system.services.database = {
      redis.enable = true;
      postgresql.enable = true;
    };

    services = {
      nextcloud = {
        enable = true;
        package = pkgs.nextcloud27;

        nginx.recommendedHttpHeaders = true;
        https = true;
        hostName = domain;

        home = "/srv/storage/nextcloud";
        maxUploadSize = "4G";
        enableImagemagick = true;

        extraApps = with config.services.nextcloud.package.packages.apps; {
          inherit news contacts calendar tasks;
        };

        autoUpdateApps = {
          enable = true;
          startAt = "02:00";
        };

        config = {
          overwriteProtocol = "https";
          extraTrustedDomains = ["https://${toString domain}"];
          trustedProxies = ["https://${toString domain}"];
          adminuser = "notashelf";
          adminpassFile = config.age.secrets.nextcloud-secret.path;
          defaultPhoneRegion = "TR";

          # database
          dbtype = "pgsql";
          dbhost = "/run/postgresql";
          dbname = "nextcloud";
        };

        caching.redis = true;
        extraOptions = {
          redis = {
            host = "/run/redis-default/redis.sock";
            dbindex = 0;
            timeout = 1.5;
          };
        };
      };
    };

    systemd.services = {
      phpfpm-nextcloud.aliases = ["nextcloud.service"];
      "nextcloud-setup" = {
        requires = ["postgresql.service"];
        after = ["postgresql.service"];
        serviceConfig = {
          Restart = "on-failure";
          RestartSec = "10s";
        };
      };
    };
  };
}

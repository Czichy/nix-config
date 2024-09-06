{
  # https://github.com/NixOS/nixpkgs/issues/45492
  # Set limits for esync.
  systemd.extraConfig = "DefaultLimitNOFILE=1048576";
  systemd.user.extraConfig = "DefaultLimitNOFILE=32000";

  security = {
    pam = {
      # fix "too many files open" errors while writing a lot of data at once
      # (e.g. when building a large package)
      # if this, somehow, doesn't meet your requirements you may just bump the numbers up
      loginLimits = [
        {
          domain = "@czichy";
          item = "stack";
          type = "-";
          value = "unlimited";
        }
        {
          domain = "*";
          # domain = "@wheel";
          item = "nofile";
          type = "soft";
          value = "524288";
        }
        {
          domain = "*";
          # domain = "@wheel";
          item = "nofile";
          type = "hard";
          value = "1048576";
        }
      ];

      services = let
        ttyAudit = {
          enable = true;
          enablePattern = "*";
        };
      in {
        # Allow screen lockers such as Swaylock or gtklock) to also unlock the screen.
        swaylock.text = "auth include login";
        gtklock.text = "auth include login";

        login = {
          inherit ttyAudit;
          setLoginUid = true;
        };

        sshd = {
          inherit ttyAudit;
          setLoginUid = true;
        };

        sudo = {
          inherit ttyAudit;
          setLoginUid = true;
        };
      };
    };
  };
}

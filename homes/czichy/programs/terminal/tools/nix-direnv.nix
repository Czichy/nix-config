{
  config,
  pkgs,
  ...
}: {
  home.sessionVariables = {
    DIRENV_LOG_FORMAT = "";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config.whitelist = {
      prefix = [
        "${config.home.homeDirectory}/projects/tradingjournalrs"
        "${config.home.homeDirectory}/projects/seeking-edge"
        "${config.home.homeDirectory}/projects/ibkr_rust"
        "${config.home.homeDirectory}/projects/nixos-flake"
        "${config.home.homeDirectory}/Dokumente/finanzen/ledger"
      ];
    };
    stdlib = ''
      : ''${XDG_CACHE_HOME:=$HOME/.cache}
      declare -A direnv_layout_dirs
      direnv_layout_dir() {
          echo "''${direnv_layout_dirs[$PWD]:=$(
              echo -n "$XDG_CACHE_HOME"/direnv/layouts/
              echo -n "$PWD" | ${pkgs.perl}/bin/shasum| cut -d ' ' -f 1
          )}"
      }
    '';

    # we should probably do this ourselves
    enableNushellIntegration = true;
    # enableBashIntegration = _ (isModuleLoadedAndEnabled config "tensorfiles.hm.programs.shells.bash");
    # enableFishIntegration = _ (isModuleLoadedAndEnabled config "tensorfiles.hm.programs.shells.fish");
    # enableNushellIntegration = _ (
    #   isModuleLoadedAndEnabled config "tensorfiles.hm.programs.shells.nushell"
    # );
    # enableZshIntegration = _ (isModuleLoadedAndEnabled config "tensorfiles.hm.programs.shells.zsh");
  };
}

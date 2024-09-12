{
  lib,
  pkgs,
  osConfig,
  inputs',
  ...
}: let
  inherit (lib) mkIf;

  dev = osConfig.modules.device;
  acceptedTypes = ["desktop" "laptop" "hybrid" "server" "lite"];
in {
  config = mkIf (builtins.elem dev.type acceptedTypes) {
    home.shellAliases = {
      "helix" = "hx";
    };
    programs.helix = {
      enable = false;
      package = inputs'.helix.packages.default.overrideAttrs (self: {
        makeWrapperArgs = with pkgs;
          self.makeWrapperArgs
          or []
          ++ [
            "--suffix"
            "PATH"
            ":"
            (lib.makeBinPath [
              clang-tools
              marksman
              nil
              luajitPackages.lua-lsp
              nodePackages.bash-language-server
              nodePackages.vscode-css-languageserver-bin
              nodePackages.vscode-langservers-extracted
              nodePackages.prettier
              rustfmt
              rust-analyzer
              black
              alejandra
              shellcheck
            ])
          ];
      });
      settings = {
        #theme = "dracula";
        theme = "catppuccin_mocha_transparent";
        icons = "nerdfonts";
        settings.keys = import ./keys.nix;
        editor = import ./editor.nix;
      };
      # override catppuccin theme and remove background to fix transparency
      themes = {
        catppuccin_mocha_transparent = {
          "inherits" = "catppuccin_mocha";
          "ui.virtual.inlay-hint" = {
            fg = "surface1";
          };
          "ui.background" = "{}";
        };
      };

      languages = import ./languages.nix {inherit lib pkgs;};
    };

    # home.packages = with pkgs; [
    #   # some other lsp related packages / dev tools
    #   lldb # debugging stuff
    #   # gopls # go
    #   # revive # go
    #   rust-analyzer # rust
    #   texlab # latex
    #   # zls # zig
    #   #elixir_ls # broken
    #   gcc # C/++
    #   uncrustify # source code beautifier
    #   black # python
    #   alejandra # nix formatting
    #   shellcheck # bash
    #   gawk
    #   # haskellPackages.haskell-language-server
    #   # nodePackages.typescript-language-server
    #   # java-language-server
    #   # kotlin-language-server
    #   nodePackages.vls
    #   # nodePackages.yaml-language-server
    #   nodePackages.jsonlint
    #   # nodePackages.yarn
    #   # nodePackages.pnpm
    #   sumneko-lua-language-server
    #   # nodePackages.vscode-langservers-extracted
    #   cargo
    # ];
  };
}

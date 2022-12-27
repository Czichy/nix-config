{
  config,
  pkgs,
  ...
}: let
  inherit (config.colorscheme) colors;
in {
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    enableCompletion = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;
    sessionVariables = {LC_ALL = "en_US.UTF-8";};

    completionInit = ''
      autoload -U compinit
      zstyle ':completion:*' menu select
      zmodload zsh/complist
      compinit -d "$XDG_CACHE_HOME"/zsh/zcompdump-"$ZSH_VERSION"
      _comp_options+=(globdots)
      bindkey -M menuselect 'h' vi-backward-char
      bindkey -M menuselect 'k' vi-up-line-or-history
      bindkey -M menuselect 'l' vi-forward-char
      bindkey -M menuselect 'j' vi-down-line-or-history
      bindkey -v '^?' backward-delete-char
    '';

    initExtra = ''
      autoload -U url-quote-magic
      zle -N self-insert url-quote-magic
      export FZF_DEFAULT_OPTS="
      --color bg:#${colors.base00}
      --color bg+:#${colors.base01}
      --color fg:#${colors.base04}
      --color fg+:#${colors.base06}
      --color hl:#${colors.base0D}
      --color hl+:#${colors.base0D}
      --color header:#${colors.base0D}
      --color info:#${colors.base0A}
      --color marker:#${colors.base0C}
      --color pointer:#${colors.base0C}
      --color prompt:#${colors.base0A}
      --color spinner:#${colors.base0C}
      --color preview-bg:#${colors.base01}
      --color preview-fg:#${colors.base0D}
      --prompt ' '
      --pointer ''
      --layout=reverse
      -m --bind ctrl-space:toggle,pgup:preview-up,pgdn:preview-down
      "

      function extract() {
          if [ -z "$1" ]; then
             # display usage if no parameters given
             echo "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz|.zlib|.cso>"
             echo "       extract <path/file_name_1.ext> [path/file_name_2.ext] [path/file_name_3.ext]"
          else
             for n in "$@"
             do
               if [ -f "$n" ] ; then
                   case "''${n%,}" in
                     *.cbt|*.tar.bz2|*.tar.gz|*.tar.xz|*.tbz2|*.tgz|*.txz|*.tar)
                                  tar xvf "$n"       ;;
                     *.lzma)      unlzma ./"$n"      ;;
                     *.bz2)       bunzip2 ./"$n"     ;;
                     *.cbr|*.rar) unrar x -ad ./"$n" ;;
                     *.gz)        gunzip ./"$n"      ;;
                     *.cbz|*.epub|*.zip) unzip ./"$n"   ;;
                     *.z)         uncompress ./"$n"  ;;
                     *.7z|*.apk|*.arj|*.cab|*.cb7|*.chm|*.deb|*.dmg|*.iso|*.lzh|*.msi|*.pkg|*.rpm|*.udf|*.wim|*.xar)
                                  7z x ./"$n"        ;;
                     *.xz)        unxz ./"$n"        ;;
                     *.exe)       cabextract ./"$n"  ;;
                     *.cpio)      cpio -id < ./"$n"  ;;
                     *.cba|*.ace) unace x ./"$n"     ;;
                     *.zpaq)      zpaq x ./"$n"      ;;
                     *.arc)       arc e ./"$n"       ;;
                     *.cso)       ciso 0 ./"$n" ./"$n.iso" && \
                                       extract "$n.iso" && \rm -f "$n" ;;
                     *.zlib)      zlib-flate -uncompress < ./"$n" > ./"$n.tmp" && \
                                       mv ./"$n.tmp" ./"''${n%.*zlib}" && rm -f "$n"   ;;
                     *)
                                  echo "extract: '$n' - unknown archive method"
                                  return 1
                                  ;;
                   esac
               else
                   echo "'$n' - file doesn't exist"
                   return 1
               fi
             done
        fi
        }

        # Colors
        autoload -Uz colors && colors

        # Group matches and describe.
        zstyle ':completion:*' sort false
        zstyle ':completion:complete:*:options' sort false
        zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'
        zstyle ':completion:*' special-dirs true
        zstyle ':completion:*' rehash true

        zstyle ':completion:*' menu yes select # search
        zstyle ':completion:*' list-grouped false
        zstyle ':completion:*' list-separator '''
        zstyle ':completion:*' group-name '''
        zstyle ':completion:*' verbose yes
        zstyle ':completion:*:matches' group 'yes'
        zstyle ':completion:*:warnings' format '%F{red}%B-- No match for: %d --%b%f'
        zstyle ':completion:*:messages' format '%d'
        zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
        zstyle ':completion:*:descriptions' format '[%d]'

        # Fuzzy match mistyped completions.
        zstyle ':completion:*' completer _complete _match _approximate
        zstyle ':completion:*:match:*' original only
        zstyle ':completion:*:approximate:*' max-errors 1 numeric

        # Don't complete unavailable commands.
        zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'

        # Array completion element sorting.
        zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

        # Colors
        zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}

        # Jobs id
        zstyle ':completion:*:jobs' numbers true
        zstyle ':completion:*:jobs' verbose true

        # Autosuggest
        ZSH_AUTOSUGGEST_USE_ASYNC="true"

        while read -r option
        do
          setopt $option
        done <<-EOF
        AUTO_CD
        AUTO_LIST
        AUTO_MENU
        AUTO_PARAM_SLASH
        AUTO_PUSHD
        APPEND_HISTORY
        ALWAYS_TO_END
        COMPLETE_IN_WORD
        CORRECT
        EXTENDED_HISTORY
        HIST_EXPIRE_DUPS_FIRST
        HIST_FCNTL_LOCK
        HIST_IGNORE_ALL_DUPS
        HIST_IGNORE_DUPS
        HIST_IGNORE_SPACE
        HIST_REDUCE_BLANKS
        HIST_SAVE_NO_DUPS
        HIST_VERIFY
        INC_APPEND_HISTORY
        INTERACTIVE_COMMENTS
        MENU_COMPLETE
        NO_NOMATCH
        PUSHD_IGNORE_DUPS
        PUSHD_TO_HOME
        PUSHD_SILENT
        SHARE_HISTORY
        EOF

        while read -r option
        do
          unsetopt $option
        done <<-EOF
        CORRECT_ALL
        HIST_BEEP
        MENU_COMPLETE
        EOF

        # fzf-tab
        FZF_TAB_COMMAND=(
          ${pkgs.fzf}/bin/fzf
          --ansi
          --expect='$continuous_trigger' # For continuous completion
          --nth=2,3 --delimiter='\x00'  # Don't search prefix
          --layout=reverse --height="''${FZF_TMUX_HEIGHT:=50%}"
          --tiebreak=begin -m --bind=tab:down,btab:up,change:top,ctrl-space:toggle --cycle
          '--query=$query'   # $query will be expanded to query string at runtime.
          '--header-lines=$#headers' # $#headers will be expanded to lines of headers at runtime
        )

        # If this is an xterm set the title to user@host:dir
        case "$TERM" in
        xterm*|rxvt*|Eterm|aterm|kterm|gnome*|alacritty)
          TERM_TITLE=$'\e]0;%n@%m: %1~\a'
            ;;
        *)
            ;;
        esac

        function run() {
          nix run nixpkgs#$@
        }

        command_not_found_handler() {
          printf 'Command not found ->\033[01;32m %s\033[0m \n' "$0" >&2
          return 127
        }

        clear
    '';
    history = {
      path = "${config.xdg.dataHome}/zsh/zsh_history";
      share = true;
      save = 10000;
      size = 10000;
      expireDuplicatesFirst = true;
      ignoreDups = true;
      ignoreSpace = true;
    };

    dirHashes = {
      docs = "$HOME/Documents";
      notes = "$HOME/Cloud/Notes";
      dev = "$HOME/Dev";
      dotfiles = "$HOME/.config/nixos";
      dl = "$HOME/Downloads";
      vids = "$HOME/Media/Videos";
      music = "$HOME/Media/Music";
      screenshots = "$HOME/Pictures/Screenshots";
      media = "$HOME/Media";
    };

    shellAliases = let
      # for setting up license in new projects
      gpl3 = pkgs.fetchurl {
        url = "https://www.gnu.org/licenses/gpl-3.0.txt";
        sha256 = "OXLcl0T2SZ8Pmy2/dmlvKuetivmyPd5m1q+Gyd+zaYY=";
      };
    in
      with pkgs; {
        rebuild = "doas nix-store --verify; pushd ~dotfiles && doas nixos-rebuild switch --flake .# && notify-send \"Done\"&& bat cache --build; popd";
        cleanup = "doas nix-collect-garbage --delete-older-than 7d";
        bloat = "nix path-info -Sh /run/current-system";
        curgen = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
        ytmp3 = ''
          ${lib.getExe yt-dlp} -x --continue --add-metadata --embed-thumbnail --audio-format mp3 --audio-quality 0 --metadata-from-title="%(artist)s - %(title)s" --prefer-ffmpeg -o "%(title)s.%(ext)s"
        '';
        cat = "${lib.getExe bat} --style=plain";
        grep = "${lib.getExe ripgrep}";
        du = "${lib.getExe du-dust}";
        ps = "${lib.getExe procs}";
        m = "mkdir -p";
        fcd = "cd $(find -type d | fzf)";
        ls = "${lib.getExe exa} -h --git --color=auto --group-directories-first -s extension";
        l = "ls -lF --time-style=long-iso";
        sc = "sudo systemctl";
        scu = "systemctl --user ";
        la = "${lib.getExe exa} -lah";
        tree = "${lib.getExe exa} --tree --icons";
        http = "${lib.getExe python3} -m http.server";
        burn = "pkill -9";
        diff = "diff --color=auto";
        killall = "pkill";
        gpl3init = "cp ${gpl3} LICENSE";
        ".." = "cd ..";
        "..." = "cd ../../";
        "...." = "cd ../../../";
        "....." = "cd ../../../../";
        "......" = "cd ../../../../../";
        v = "nvim";
        g = "git";
        sudo = "doas";
      };

    plugins = with pkgs; [
      {
        name = "zsh-nix-shell";
        src = zsh-nix-shell;
        file = "share/zsh-nix-shell/nix-shell.plugin.zsh";
      }
      {
        name = "zsh-vi-mode";
        src = zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
      {
        name = "fzf-tab";
        file = "fzf-tab.plugin.zsh";
        src = fetchFromGitHub {
          owner = "Aloxaf";
          repo = "fzf-tab";
          rev = "426271fb1bbe8aa88ff4010ca4d865b4b0438d90";
          sha256 = "sha256-RXqEW+jwdul2mKX86Co6HLsb26UrYtLjT3FzmHnwfAA=";
        };
      }
      {
        name = "fast-syntax-highlighting";
        file = "fast-syntax-highlighting.plugin.zsh";
        src = fetchFromGitHub {
          owner = "zdharma-continuum";
          repo = "fast-syntax-highlighting";
          rev = "7c390ee3bfa8069b8519582399e0a67444e6ea61";
          sha256 = "sha256-wLpgkX53wzomHMEpymvWE86EJfxlIb3S8TPy74WOBD4=";
        };
      }
      {
        name = "zsh-autopair";
        file = "zsh-autopair.plugin.zsh";
        src = fetchFromGitHub {
          owner = "hlissner";
          repo = "zsh-autopair";
          rev = "34a8bca0c18fcf3ab1561caef9790abffc1d3d49";
          sha256 = "1h0vm2dgrmb8i2pvsgis3lshc5b0ad846836m62y8h3rdb3zmpy1";
        };
      }
    ];
  };
}

{pkgs, ...}: {
  imports = [
    ./bash.nix
    ./direnv.nix
    ./nano.nix
    ./zsh.nix
  ];

  programs = {
    # less pager
    less.enable = true;

    # run commands without installing the programs
    comma.enable = true;
  };
}

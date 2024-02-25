{
  programs.neovim-flake.settings.vim = {
    terminal = {
      toggleterm = {
        enable = true;
        mappings.open = "<C-t>";
        direction = "tab";
        lazygit = {
          enable = true;
          direction = "tab";
        };
      };
    };
  };
}

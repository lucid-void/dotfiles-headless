{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    withRuby = false;
    # Only on nvim's own PATH (treesitter parsers, Mason), so Nix's gcc doesn't
    # shadow the host's for everything else on the node.
    extraPackages = with pkgs; [
      gcc
      gnumake
      tree-sitter
      nodejs
      python3
    ];
  };

  # LazyVim starter. recursive: ~/.config/nvim stays a real directory, because
  # lazy.nvim and LazyVim write lazy-lock.json and lazyvim.json next to init.lua.
  xdg.configFile."nvim" = {
    source = ./nvim;
    recursive = true;
  };
}

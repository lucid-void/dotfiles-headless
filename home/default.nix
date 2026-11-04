{ pkgs, ... }:
{
  imports = [
    ./shell.nix
    ./tools.nix
    ./tmux.nix
    ./fastfetch.nix
  ];

  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  nix = {
  package = pkgs.nix;  # only tells home-manager which nix.conf format to write
  settings.experimental-features = [ "nix-command" "flakes" ];
};

  # Non-NixOS host (Arch/Ubuntu): fixes XDG_DATA_DIRS, locales, terminfo paths.
  targets.genericLinux.enable = true;
  xdg.enable = true;

  home.packages = with pkgs; [
    fd
    ripgrep
    pokeget-rs
  ];

  home.sessionVariables = {
    EDITOR = "vim";
    PAGER = "less";
    LESS = "-R --mouse";
  };
}

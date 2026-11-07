{ pkgs, ... }:
{
  imports = [
    ./shell.nix
    ./tools.nix
    ./tmux.nix
    ./fastfetch.nix
    ./git.nix
    ./nvim.nix
    ./opencode.nix
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
    pokeget-rs

    # automation
    ansible

    # git
    gh
    lazygit

    # fetching and archives
    curl
    wget
    rsync
    rclone
    unzip
    zip

    # CLI utilities
    jq
    yq-go
    btop
    gdu
    shellcheck
    shfmt
  ];

  # Tools installed outside Nix (Claude Code, cargo install, krew, LM Studio).
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
    "$HOME/.krew/bin"
    "$HOME/.lmstudio/bin"
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    PAGER = "less";
    LESS = "-R --mouse";
  };
}

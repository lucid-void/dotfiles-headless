{ pkgs, ... }:
let
  # nixpkgs has the wrong node_modules hash for opencode 2.2.5, so it fails to
  # build. Only applies to that version; delete once nixpkgs has moved past it.
  opencode =
    if pkgs.opencode.version == "2.2.5" then
      pkgs.opencode.overrideAttrs (old: {
        node_modules = old.node_modules.overrideAttrs {
          outputHash = "sha256-prx9dX7kUvs/E3zopkaPk5LXh3xJAy5sZeum/W8L7cA=";
        };
      })
    else
      pkgs.opencode;
in
{
  imports = [
    ./shell.nix
    ./tools.nix
    ./tmux.nix
    ./fastfetch.nix
    ./git.nix
    ./nvim.nix
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

    # agents and automation
    opencode
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

  # Tools installed outside Nix (Claude Code, cargo install, krew).
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
    "$HOME/.krew/bin"
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    PAGER = "less";
    LESS = "-R --mouse";
  };
}

{ lib, pkgs, ... }:
let
  # .git and friends are excluded by programs.fd.ignores below.
  fdArgs = "--hidden --follow";
in
{
  programs.eza = {
    enable = true;
    enableZshIntegration = true; # ls, ll, la, lt, lla aliases
    icons = "auto"; # needs a Nerd Font in your *local* terminal
    git = true;
    extraOptions = [ "--group-directories-first" ];
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "Catppuccin Macchiato";
      style = "numbers,changes,header";
      italic-text = "always";
    };
    themes."Catppuccin Macchiato" = {
      src = pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "bat";
        rev = "6810349b28055dce54076712fc05fc68da4b8ec0";
        hash = "sha256-lJapSgRVENTrbmpVyn+UQabC9fpV1G1e+CdlJ090uvg=";
      };
      file = "themes/Catppuccin Macchiato.tmTheme";
    };
  };

  programs.fd = {
    enable = true;
    ignores = [
      ".git/"
      "node_modules/"
      ".venv/"
      "target/"
    ];
  };

  programs.ripgrep = {
    enable = true;
    arguments = [
      "--smart-case"
      "--hidden"
      "--glob=!.git/"
      "--glob=!node_modules/"
      "--glob=!.venv/"
      "--glob=!target/"
      # Truncate minified lines, but keep a marker so a hit is never invisible.
      "--max-columns=200"
      "--max-columns-preview"
    ];
  };

  programs.bottom = {
    enable = true;
    settings = lib.importTOML ./files/bottom.toml; # Catppuccin Macchiato
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true; # Ctrl-T files, Ctrl-R history, Alt-C cd
    defaultCommand = "fd --type f ${fdArgs}";
    defaultOptions = [
      "--height 40%"
      "--layout reverse"
      "--border"
      "--inline-info"
    ];
    # Catppuccin Macchiato
    colors = {
      "bg+" = "#363a4f";
      bg = "#24273a";
      spinner = "#f4dbd6";
      hl = "#ed8796";
      fg = "#cad3f5";
      header = "#ed8796";
      info = "#c6a0f6";
      pointer = "#f4dbd6";
      marker = "#b7bdf8";
      "fg+" = "#cad3f5";
      prompt = "#c6a0f6";
      "hl+" = "#ed8796";
      selected-bg = "#494d64";
    };
    fileWidget = {
      command = "fd --type f ${fdArgs}";
      options = [ "--preview 'bat --color=always --style=numbers --line-range=:300 {}'" ];
    };
    changeDirWidget = {
      command = "fd --type d ${fdArgs}";
      options = [ "--preview 'eza --tree --level=2 --color=always --icons=auto {}'" ];
    };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true; # cd <dir> jumps, cdi for interactive
    options = [ "--cmd cd" ];
  };
}

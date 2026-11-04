{ ... }:
let
  fdExcludes = "--hidden --follow --exclude .git";
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
      theme = "TwoDark";
      style = "numbers,changes,header";
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true; # Ctrl-T files, Ctrl-R history, Alt-C cd
    defaultCommand = "fd --type f ${fdExcludes}";
    defaultOptions = [
      "--height 40%"
      "--layout reverse"
      "--border"
    ];
    fileWidget = {
      command = "fd --type f ${fdExcludes}";
      options = [ "--preview 'bat --color=always --style=numbers --line-range=:300 {}'" ];
    };
    changeDirWidget = {
      command = "fd --type d ${fdExcludes}";
      options = [ "--preview 'eza --tree --level=2 --color=always --icons=auto {}'" ];
    };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true; # z <dir>, zi for interactive
  };
}

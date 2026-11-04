{ config, lib, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    defaultKeymap = "emacs";

    history = {
      size = 50000;
      save = 50000;
      path = "${config.xdg.stateHome}/zsh/history";
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
      extended = true;
    };

    shellAliases = {
      cat = "bat --paging=never --style=plain";
      ff = "fastfetch";
      poke = "pokeget random --hide-name | fastfetch --file-raw -";
    };

    # Belt and braces: Debian/Ubuntu zsh reads /etc/zsh/*, not the /etc/zshrc the
    # Nix installer patches, so make sure the Nix profile is on PATH.
    envExtra = ''
      if ! command -v nix >/dev/null 2>&1 \
        && [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
      fi
    '';

    initContent = lib.mkMerge [
      ''
        setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS INTERACTIVE_COMMENTS
        zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
        zstyle ':completion:*' menu select
        bindkey '^[[1;5C' forward-word
        bindkey '^[[1;5D' backward-word
      ''
      # Greeting: Pokémon + system info, once per login, never inside tmux.
      (lib.mkAfter ''
        if [[ -o interactive && -z "$TMUX" && -z "$DOTFILES_GREETED" && -t 1 ]]; then
          export DOTFILES_GREETED=1
          pokeget random --hide-name 2>/dev/null | fastfetch --file-raw - 2>/dev/null || fastfetch
        fi
      '')
    ];
  };

  # Login shells stay bash (always in /etc/shells, no lockout if /nix breaks);
  # interactive bash hands off to zsh. Falls back to plain bash if zsh is missing.
  programs.bash = {
    enable = true;
    initExtra = ''
      if [[ $- == *i* && -z "$ZSH_VERSION" && -z "$NO_ZSH" ]] && command -v zsh >/dev/null 2>&1; then
        if shopt -q login_shell; then exec zsh -l; else exec zsh; fi
      fi
    '';
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;
      format = lib.concatStrings [
        "$username"
        "$hostname"
        "$directory"
        "$git_branch"
        "$git_status"
        "$nix_shell"
        "$cmd_duration"
        "$line_break"
        "$character"
      ];
      # Always show user@host — it's the whole point on remote nodes.
      username = {
        show_always = true;
        format = "[$user]($style)@";
        style_user = "bold blue";
        style_root = "bold red";
      };
      hostname = {
        ssh_only = false;
        format = "[$hostname]($style) ";
        style = "bold green";
      };
      directory = {
        truncation_length = 4;
        truncate_to_repo = true;
      };
      cmd_duration.min_time = 2000;
      nix_shell.format = "[❄ $name]($style) ";
      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };
    };
  };
}

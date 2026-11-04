{ config, lib, pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion = {
      enable = true;
      highlight = "fg=#8087a2"; # Catppuccin overlay1
    };
    syntaxHighlighting.enable = true;
    defaultKeymap = "viins";

    history = {
      size = 1000000;
      save = 1000000;
      path = "${config.xdg.stateHome}/zsh/history";
      ignoreDups = true;
      ignoreAllDups = true;
      saveNoDups = true;
      findNoDups = true;
      ignoreSpace = true;
      share = true;
      extended = true;
    };

    shellAliases = {
      cat = "bat --paging=never --style=plain";
      ff = "fastfetch";
      poke = "pokeget random --hide-name | fastfetch --file-raw -";
      ".." = "cd ..";
      "..." = "cd ../..";
      grep = "rg --color=auto";
      find = "fd";
      lg = "lazygit";
      c = "clear";
      python = "python3";
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
        setopt COMPLETE_IN_WORD NO_BEEP NO_BG_NICE HIST_VERIFY

        # `menu no` is required by fzf-tab: with `menu select` zsh draws its own
        # menu and fzf-tab never takes over.
        zstyle ':completion:*' menu no
        zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
        zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
        zstyle ':completion:*' list-separator '─'
        zstyle ':completion:*' group-name '''
        zstyle ':completion:*' format $'\e[1;38;2;183;189;248m── %d ──\e[0m'
        zstyle ':completion:*:descriptions' format $'\e[1;38;2;183;189;248m%d\e[0m'

        zstyle ':fzf-tab:complete:cd:*'         fzf-preview 'eza --tree --icons --color=always $realpath 2>/dev/null | head -50'
        zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza --tree --icons --color=always $realpath 2>/dev/null | head -50'
        zstyle ':fzf-tab:complete:*'            fzf-preview 'bat --color=always $realpath 2>/dev/null | head -50'
        zstyle ':fzf-tab:*' switch-group ',' '.'
        zstyle ':fzf-tab:*' continuous-trigger '/'

        ${builtins.readFile ./zsh/vi-mode.zsh}
        ${builtins.readFile ./zsh/keyseq.zsh}
      ''
      # After vi-mode.zsh: autopair binds Backspace, which that file also sets.
      # fzf-tab also has to follow fzf (910), which rebinds Tab, and precede
      # syntax highlighting (1200), which wraps widgets.
      (lib.mkOrder 1010 ''
        source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh

        source ${pkgs.zsh-autopair}/share/zsh/zsh-autopair/autopair.zsh

        # fzf-git: Ctrl-G Ctrl-{B,T,H,R,S} for branches, tags, hashes, remotes, stashes.
        source ${pkgs.fzf-git-sh}/share/fzf-git-sh/fzf-git.sh

        # OMZ sudo: its default Esc-Esc collides with vi mode, so use Alt-s instead.
        source ${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/sudo/sudo.plugin.zsh
        bindkey -M viins '^[s' sudo-command-line
        bindkey -M vicmd '^[s' sudo-command-line
        bindkey -r -M viins '^[^['
        bindkey -r -M vicmd '^[^['
      '')
      (lib.mkAfter ''
        # Claude Code snapshots this shell and replays it before every command,
        # so undo what trades exactness for ergonomics. The rg config truncates
        # long lines and changes what a search means; eza, bat, rg and fd aren't
        # drop-in for ls, cat, grep and find; zoxide's self-check misfires on the
        # replayed snapshot, printing a warning before each command.
        if [[ -n "$CLAUDECODE" ]]; then
          unset RIPGREP_CONFIG_PATH
          unalias ls ll la lt lla cat grep find 2>/dev/null
          export _ZO_DOCTOR=0
        fi

        # Greeting: Pokémon + system info, once per login, never inside tmux.
        if [[ -o interactive && -z "$TMUX" && -z "$CLAUDECODE" && -z "$DOTFILES_GREETED" && -t 1 ]]; then
          export DOTFILES_GREETED=1
          pokeget random --hide-name 2>/dev/null | fastfetch --file-raw - 2>/dev/null || fastfetch
        fi
      '')
      # Machine-specific overrides, after everything (zoxide is 2000).
      (lib.mkOrder 2100 ''
        [[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
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
    settings = lib.importTOML ./files/starship.toml;
  };

  # Completion for ~1000 CLIs, on top of whatever compsys already finds.
  programs.carapace = {
    enable = true;
    enableZshIntegration = true;
  };
  home.sessionVariables.CARAPACE_BRIDGES = "zsh,fish,bash,inshellisense";
}

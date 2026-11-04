{ config, ... }:
{
  programs.tmux = {
    enable = true;
    shortcut = "a"; # prefix = C-a; C-a C-a sends a literal C-a
    shell = "${config.programs.zsh.package}/bin/zsh";
    terminal = "tmux-256color";
    baseIndex = 1;
    escapeTime = 10;
    historyLimit = 50000;
    keyMode = "vi";
    mouse = true;
    clock24 = true;
    focusEvents = true;

    extraConfig = ''
      # True colour through to the outer terminal
      set -ag terminal-overrides ",*:RGB"

      set -g renumber-windows on
      set -g set-titles on
      set -g set-titles-string "#h: #S/#W"

      # Long enough to read the reload message
      set -g display-time 2000

      # The clock only shows minutes; don't redraw over SSH for nothing
      set -g status-interval 60

      # Carries Claude Code's notification and progress escapes (and kitty
      # graphics/sixel) out to the terminal drawing the session, SSH included.
      set -g allow-passthrough on

      # Shift+Enter as a distinct key, so Claude Code can insert a newline.
      # If a key ever arrives as a stray escape, this pair is the first suspect.
      set -s extended-keys on
      set -as terminal-features ",xterm*:extkeys"

      # Copy to the local clipboard via OSC 52, works through SSH
      set -g set-clipboard on

      # C-a a: jump to last window (screen habit)
      bind a last-window

      # Window cycling
      bind BSpace previous-window
      bind Enter previous-window
      bind Space next-window

      # Splits/new windows keep the current directory
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      unbind '"'
      unbind %
      bind c new-window -c "#{pane_current_path}"

      # Vim-style pane navigation and resizing
      bind -r h select-pane -L
      bind -r j select-pane -D
      bind -r k select-pane -U
      bind -r l select-pane -R
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # Vi copy mode
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi C-v send -X rectangle-toggle
      bind -T copy-mode-vi y send -X copy-selection-and-cancel
      bind -T copy-mode-vi Escape send -X cancel

      bind r source-file ~/.config/tmux/tmux.conf \; display "tmux.conf reloaded"

      # Status bar: Catppuccin Macchiato, plain `Z` zoom marker (no Nerd Font needed)
      set -g status-position bottom
      set -g status-style "bg=#24273a,fg=#cad3f5"
      set -g status-left "#[fg=#24273a,bg=#8aadf4,bold] #S #[fg=#8aadf4,bg=#24273a]"
      set -g status-right "#[fg=#363a4f,bg=#24273a]#[fg=#cad3f5,bg=#363a4f] %H:%M #[fg=#8aadf4,bg=#363a4f]#[fg=#24273a,bg=#8aadf4,bold] #h "
      set -g status-left-length 30
      set -g status-right-length 50
      setw -g window-status-format "#[fg=#6e738d,bg=#24273a] #I:#W#{?window_zoomed_flag,Z,} "
      setw -g window-status-current-format "#[fg=#24273a,bg=#c6a0f6]#[fg=#24273a,bg=#c6a0f6,bold] #I:#W#{?window_zoomed_flag,Z,} #[fg=#c6a0f6,bg=#24273a]"
      set -g pane-border-style        "fg=#494d64"
      set -g pane-active-border-style "fg=#c6a0f6"
      set -g message-style            "bg=#363a4f,fg=#cad3f5"
      set -g message-command-style    "bg=#363a4f,fg=#cad3f5"
      set -g mode-style               "bg=#494d64,fg=#cad3f5"
    '';
  };
}

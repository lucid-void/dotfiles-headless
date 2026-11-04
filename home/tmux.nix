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

      # C-a a: jump to last window (screen habit)
      bind a last-window

      # Splits/new windows keep the current directory
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"

      # Vim-style pane navigation and resizing
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # Vi copy mode
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send -X copy-selection-and-cancel

      bind r source-file ~/.config/tmux/tmux.conf \; display "tmux.conf reloaded"

      # Status bar: host on the left so you know which node you're on
      set -g status-position bottom
      set -g status-style "bg=default,fg=white"
      set -g status-left "#[bold,fg=green]#h #[fg=blue]#S #[default]"
      set -g status-left-length 40
      set -g status-right "#[fg=yellow]%Y-%m-%d %H:%M"
      set -g window-status-current-style "bold,fg=cyan"
      set -g pane-active-border-style "fg=cyan"
    '';
  };
}

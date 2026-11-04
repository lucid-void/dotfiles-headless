export KEYTIMEOUT=1

# ── Key bindings ───────────────────────────────────────────────
# `bindkey -v` (defaultKeymap in shell.nix) swaps zsh's emacs keymap out for the vi ones, and those
# bind the vi commands and almost nothing else — Home, End, Delete and the
# Ctrl/Alt-arrow variants all land on undefined-key, which is why they read as
# dead keys. Everything they used to do has to be re-bound here, in *both*
# keymaps, since a key that only works in insert mode is its own bug report.
#
# Terminals also disagree on what these keys emit. xterm-family terminals
# (ghostty, alacritty, foot, kitty) send ^[[H / ^[[F in normal cursor-key mode
# and ^[OH / ^[OF once something switches the terminal into application mode;
# tmux and the linux console send ^[[1~ / ^[[4~; rxvt sends ^[[7~ / ^[[8~. The
# alternative — forcing application mode with `echoti smkx` on every line — needs
# correct terminfo on every host and leaks the mode into anything that doesn't
# reset it, so bind every variant instead. Unused bindings cost nothing.
_bindkey_both() {
  local widget=$1 seq
  for seq in "${@:2}"; do
    bindkey -M viins "$seq" "$widget"
    bindkey -M vicmd "$seq" "$widget"
  done
}

_bindkey_both beginning-of-line '^[[H'    '^[OH'    '^[[1~' '^[[7~'
_bindkey_both end-of-line       '^[[F'    '^[OF'    '^[[4~' '^[[8~'
_bindkey_both delete-char       '^[[3~'
_bindkey_both forward-word      '^[[1;5C' '^[[1;3C' '^[[5C' '^[Oc' '^[f'  # Ctrl/Alt-Right
_bindkey_both backward-word     '^[[1;5D' '^[[1;3D' '^[[5D' '^[Od' '^[b'  # Ctrl/Alt-Left
_bindkey_both kill-word         '^[[3;5~'                                 # Ctrl-Delete

# Backstop for anything the literal list missed — the linux console, or an
# unusual TERM. Silently skipped when the capability isn't in the terminfo db.
zmodload -i zsh/terminfo
[[ -n "${terminfo[khome]}" ]] && _bindkey_both beginning-of-line "${terminfo[khome]}"
[[ -n "${terminfo[kend]}"  ]] && _bindkey_both end-of-line       "${terminfo[kend]}"
[[ -n "${terminfo[kdch1]}" ]] && _bindkey_both delete-char       "${terminfo[kdch1]}"

unfunction _bindkey_both

# vi mode binds Backspace to vi-backward-delete-char, which refuses to delete
# past the column where insert mode began — it reads as the key having died
# mid-line. backward-delete-char has no such limit. ^? is Backspace; ^H is what
# xterm-family terminals send for Ctrl-Backspace.
bindkey -M viins '^?' backward-delete-char
bindkey -M viins '^H' backward-kill-word

# Emacs-style editing inside insert mode: muscle memory that predates vi mode
# and that nothing else claims. ^R / ^T / Alt-C are fzf's and ^G is fzf-git's,
# so they are deliberately absent. ^A only lands outside tmux — inside a session
# tmux takes it as the prefix.
bindkey -M viins '^A' beginning-of-line
bindkey -M viins '^E' end-of-line
bindkey -M viins '^K' kill-line
bindkey -M viins '^U' backward-kill-line
bindkey -M viins '^W' backward-kill-word
bindkey -M viins '^Y' yank

# History search on arrow keys, in both insert and normal mode. ^[OA / ^[OB are
# the application-cursor-mode forms of the same two keys.
bindkey -M viins '^[[A' history-search-backward
bindkey -M viins '^[[B' history-search-forward
bindkey -M viins '^[OA' history-search-backward
bindkey -M viins '^[OB' history-search-forward
bindkey -M vicmd '^[[A' history-search-backward
bindkey -M vicmd '^[[B' history-search-forward
bindkey -M vicmd '^[OA' history-search-backward
bindkey -M vicmd '^[OB' history-search-forward
bindkey -M vicmd 'k'    history-search-backward
bindkey -M vicmd 'j'    history-search-forward

# Cursor shape follows the keymap: beam in insert, block in normal. These are
# DECSCUSR escapes (CSI Ps SP q), understood by alacritty, kitty, foot, wezterm
# and VTE-based terminals. Terminals that don't know the sequence ignore it, so
# there is nothing to guard against.
_cursor_beam()  { print -n '\e[5 q' }  # 5 = blinking bar
_cursor_block() { print -n '\e[2 q' }  # 2 = steady block

# Fires on every keymap change, including the Esc that leaves insert mode.
zle-keymap-select() {
  case "$KEYMAP" in
    vicmd|visual|viopp) _cursor_block ;;
    *)                  _cursor_beam  ;;
  esac
}
# Each new prompt starts in insert mode, so start from the beam. `zle -K viins`
# is belt-and-braces: without it a line abandoned in normal mode (Ctrl-C) can
# leave the next prompt in vicmd with a beam cursor.
zle-line-init() { zle -K viins; _cursor_beam }
zle -N zle-keymap-select
zle -N zle-line-init

# Hand the cursor back before running a command — otherwise a block cursor
# leaks into whatever is launched (pagers, TUIs that don't set their own).
autoload -Uz add-zsh-hook
add-zsh-hook preexec _cursor_beam

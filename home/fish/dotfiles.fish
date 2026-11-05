# The end-4 installer owns ~/.config/fish and syncs over it on every run, except
# for conf.d, so personal additions live here. A read-only config.fish symlink
# would break that sync. conf.d loads before config.fish, so upstream's aliases
# there win over anything with the same name here.
fish_add_path --global --append $HOME/.lmstudio/bin

if status is-interactive; and test "$TERM" = xterm-kitty
    alias ssh 'kitten ssh'
end

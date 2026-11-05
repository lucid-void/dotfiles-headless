# dotfiles

Portable shell environment for headless Arch / Ubuntu nodes, managed with Nix + home-manager.

**Tools:** zsh (vi mode, autosuggestions, syntax highlighting, fzf-tab, carapace), starship, eza, bat, fd, ripgrep, fzf, zoxide, tmux (prefix `C-a`), neovim (LazyVim), git + delta, lazygit, gh, bottom, btop, gdu, jq, yq, rclone, opencode, ansible, fastfetch, pokeget. Themed Catppuccin Macchiato.

## Install

```sh
# 1. Nix, multi-user (once per node)
sh <(curl -L https://nixos.org/nix/install) --daemon

# 2. Dotfiles (once per user — works for root too)
git clone <this-repo> ~/.dotfiles
~/.dotfiles/install.sh
```

First run on a fresh clone: run `nix flake lock` and commit `flake.lock` so every node gets identical versions.

## Update

```sh
# on your workstation
nix flake update && git commit -am "flake: update" && git push

# on each node / user
cd ~/.dotfiles && git pull && ./install.sh
```

Rollback: `home-manager generations`, then run the `activate` script of an older generation.

## Layout

| File | What |
|---|---|
| `flake.nix` | Inputs (nixpkgs-unstable, home-manager), `homeConfigurations.default` |
| `home/default.nix` | Base settings, plain packages, PATH, session variables |
| `home/shell.nix` | zsh, bash→zsh handoff, starship, carapace |
| `home/zsh/` | Snippets read into `.zshrc` and `.zprofile`: vi mode and key bindings, `keyseq`, functions, per-host tool integrations, Hyprland autologin |
| `home/fish/` | Personal fish additions, linked into `conf.d` |
| `home/tools.nix` | eza, bat, fd, ripgrep, bottom, fzf, zoxide |
| `home/git.nix` | git, delta, ssh client |
| `home/nvim.nix`, `home/nvim/` | neovim and the LazyVim starter config |
| `home/tmux.nix` | tmux |
| `home/fastfetch.nix` | fastfetch modules |
| `home/files/` | Theme and prompt TOML (starship, bottom) |

`default` is impure: it reads `$USER`/`$HOME`, so the same config applies to any user without listing them.

## Behaviour notes

- **Login shell stays bash.** Interactive bash `exec`s into zsh. Nothing is added to `/etc/shells`, and if `/nix` breaks you still get a working bash (important for root). To skip zsh for one session: `NO_ZSH=1 bash`. If you prefer `chsh`, add `~/.nix-profile/bin/zsh` to `/etc/shells` first.
- **Greeting:** a random Pokémon + fastfetch, once per login, never inside tmux. Run `poke` for another one, or `ff` for plain fastfetch.
- **Keys:** vi mode with emacs-style `C-a`/`C-e`/`C-k`/`C-u`/`C-w` in insert mode. fzf `Ctrl-T` (files), `Ctrl-R` (history), `Alt-C` (cd). fzf-git `Ctrl-G Ctrl-{B,T,H,R,S}`. `Alt-s` prefixes the line with sudo. `keyseq` prints what a key sends.
- **zoxide replaces `cd`:** `cd foo` jumps, `cdi` is interactive.
- **Aliases that change behaviour:** `grep`→`rg` and `find`→`fd` are different programs with different flags; use `command grep` for the real one. Under Claude Code (`CLAUDECODE=1`) these and the rg config are undone.
- **Per-machine config, not tracked:** `~/.zshrc.local`, `~/.ssh/config.private`.
- **Existing files:** anything home-manager manages (including `~/.ssh/config`) moves to `*.hm-backup`. `~/.gitconfig` is not managed, and it overrides `~/.config/git/config`, so delete it if a node has an old one.
- **Editing this repo:** the flake only sees files git knows about, so `git add` new files before running `install.sh`.
- **tmux:** `C-a` prefix, `C-a C-a` sends a literal `C-a`, `C-a a` jumps to the last window, `Space` / `BSpace` next and previous window, `|` / `-` split, `hjkl` move between panes, `HJKL` resize, `r` reloads the config. Mouse is on.
- **Desktop:** the same config runs there. `.zprofile` starts Hyprland on tty1 when it is on PATH and does nothing elsewhere; the getty autologin half is system config in the desktop repo. Fish stays owned by the end-4 installer, except `conf.d/dotfiles.fish`. `rebuild-qt` rebuilds quickshell after a Qt bump.
- **Optional tools:** `thefuck`, `kubectl` and `codium` are set up only if installed.
- **Icons** (eza, starship) need a Nerd Font in your *local* terminal; the nodes need nothing.
- If your local terminal is kitty/ghostty and the nodes complain about an unknown `TERM`, use `kitten ssh` or `TERM=xterm-256color ssh …`.

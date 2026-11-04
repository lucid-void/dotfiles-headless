# dotfiles

Portable shell environment for headless Arch / Ubuntu nodes, managed with Nix + home-manager.

**Tools:** zsh (autosuggestions, syntax highlighting), starship, eza, bat, fd, ripgrep, fzf, zoxide, tmux (prefix `C-a`), fastfetch, pokeget.

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
| `home/default.nix` | Base settings, plain packages (fd, ripgrep, pokeget) |
| `home/shell.nix` | zsh, bash→zsh handoff, starship |
| `home/tools.nix` | eza, bat, fzf, zoxide |
| `home/tmux.nix` | tmux |
| `home/fastfetch.nix` | fastfetch modules |

`default` is impure: it reads `$USER`/`$HOME`, so the same config applies to any user without listing them.

## Behaviour notes

- **Login shell stays bash.** Interactive bash `exec`s into zsh. Nothing is added to `/etc/shells`, and if `/nix` breaks you still get a working bash (important for root). To skip zsh for one session: `NO_ZSH=1 bash`. If you prefer `chsh`, add `~/.nix-profile/bin/zsh` to `/etc/shells` first.
- **Greeting:** a random Pokémon + fastfetch, once per login, never inside tmux. Run `poke` for another one, or `ff` for plain fastfetch.
- **Keys:** fzf `Ctrl-T` (files), `Ctrl-R` (history), `Alt-C` (cd). zoxide `z foo`, `zi`.
- **tmux:** `C-a` prefix, `C-a C-a` sends a literal `C-a`, `C-a a` jumps to the last window, `|` / `-` split, `hjkl` move between panes, `HJKL` resize, `r` reloads the config. Mouse is on.
- **Icons** (eza, starship) need a Nerd Font in your *local* terminal; the nodes need nothing.
- If your local terminal is kitty/ghostty and the nodes complain about an unknown `TERM`, use `kitten ssh` or `TERM=xterm-256color ssh …`.

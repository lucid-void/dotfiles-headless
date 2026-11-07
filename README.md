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
| `home/opencode.nix` | opencode config and its per-host variables |
| `home/fastfetch.nix` | fastfetch modules |
| `home/files/` | Theme and prompt TOML (starship, bottom) |

`default` is impure: it reads `$USER`/`$HOME`, so the same config applies to any user without listing them.

## Behaviour notes

- **Login shell stays bash.** Interactive bash `exec`s into zsh. Nothing is added to `/etc/shells`, and if `/nix` breaks you still get a working bash (important for root). To skip zsh for one session: `NO_ZSH=1 bash`. If you prefer `chsh`, add `~/.nix-profile/bin/zsh` to `/etc/shells` first.
- **Greeting:** a random Pokémon + fastfetch, once per login, never inside tmux. Run `poke` for another one, or `ff` for plain fastfetch.
- **Keys:** vi mode with emacs-style `C-a`/`C-e`/`C-k`/`C-u`/`C-w` in insert mode. fzf `Ctrl-T` (files), `Ctrl-R` (history), `Alt-C` (cd). fzf-git `Ctrl-G Ctrl-{B,T,H,R,S}`. `Alt-s` prefixes the line with sudo. `keyseq` prints what a key sends.
- **zoxide replaces `cd`:** `cd foo` jumps, `cdi` is interactive.
- **Aliases that change behaviour:** `grep`→`rg` and `find`→`fd` are different programs with different flags; use `command grep` for the real one. Under Claude Code (`CLAUDECODE=1`) these and the rg config are undone.
- **opencode models and endpoint** come from environment variables, which opencode expands when it reads its config. Defaults point at LM Studio on localhost; override any of them in `~/.zshrc.local`.

  Endpoint and local models:

  | Variable | Default | What |
  |---|---|---|
  | `OC_LOCAL_URL` | `http://localhost:1234/v1` | OpenAI-compatible endpoint (LM Studio, Ollama `:11434/v1`, vLLM, LiteLLM) |
  | `OC_LOCAL_KEY` | `local` | API key for that endpoint |
  | `OC_LOCAL_MODEL` | `qwen3.8-27b` | Large model the endpoint serves, as `local/<id>` |
  | `OC_LOCAL_SMALL_MODEL` | `$OC_LOCAL_MODEL` | Smaller model the endpoint serves |

  Tiers, each a `provider/model#variant` (any provider, e.g. `anthropic/claude-sonnet-5-5`):

  | Variable | Default | Agents |
  |---|---|---|
  | `OC_THINK_MODEL` | `local/$OC_LOCAL_MODEL#thinking` | `plan` |
  | `OC_BUILD_MODEL` | `local/$OC_LOCAL_MODEL#none` | `build`, which carries out the plan through tool calls |
  | `OC_AGENT_MODEL` | `local/$OC_LOCAL_SMALL_MODEL` | `general` subagent |
  | `OC_FAST_MODEL` | `local/$OC_LOCAL_SMALL_MODEL#none` | `explore`, `fast` (JSON/schema extraction, routing, applying a planned diff), `title`, `summary`, `compaction` |

  Local models get `#none` and `#thinking`, sent as `chat_template_kwargs.enable_thinking` (Qwen, GLM, Gemma templates on vLLM, SGLang, llama.cpp). A server that ignores it just runs the model's default. For another provider, pick a variant it has, or leave `#…` off. Built-in providers take their key from `opencode auth login` or their usual env var. The variables are set by interactive zsh, so a non-interactive `ssh host opencode run` doesn't see them.
- **Per-machine config, not tracked:** `~/.zshrc.local`, `~/.ssh/config.private`.
- **Existing files:** anything home-manager manages (including `~/.ssh/config`) moves to `*.hm-backup`. `~/.gitconfig` is not managed, and it overrides `~/.config/git/config`, so delete it if a node has an old one.
- **Editing this repo:** the flake only sees files git knows about, so `git add` new files before running `install.sh`.
- **tmux:** `C-a` prefix, `C-a C-a` sends a literal `C-a`, `C-a a` jumps to the last window, `Space` / `BSpace` next and previous window, `|` / `-` split, `hjkl` move between panes, `HJKL` resize, `r` reloads the config. Mouse is on.
- **Desktop:** the same config runs there. `.zprofile` starts Hyprland on tty1 when it is on PATH and does nothing elsewhere; the getty autologin half is system config in the desktop repo. Fish stays owned by the end-4 installer, except `conf.d/dotfiles.fish`. `rebuild-qt` rebuilds quickshell after a Qt bump.
- **Optional tools:** `thefuck`, `kubectl` and `codium` are set up only if installed.
- **Icons** (eza, starship) need a Nerd Font in your *local* terminal; the nodes need nothing.
- If your local terminal is kitty/ghostty and the nodes complain about an unknown `TERM`, use `kitten ssh` or `TERM=xterm-256color ssh …`.

#!/usr/bin/env bash
# Apply these dotfiles for the current user (run once per user, root included).
# Extra args are passed to `home-manager switch`, e.g. ./install.sh --show-trace
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"

export USER="${USER:-$(id -un)}"
export HOME="${HOME:-$(getent passwd "$USER" | cut -d: -f6)}"
export NIX_CONFIG="extra-experimental-features = nix-command flakes"

if ! command -v nix >/dev/null 2>&1; then
  if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  else
    echo "Nix not found. Install it first (multi-user):" >&2
    echo "  sh <(curl -L https://nixos.org/nix/install) --daemon" >&2
    exit 1
  fi
fi

# Existing dotfiles (e.g. Ubuntu's stock ~/.bashrc) are moved to *.hm-backup.
nix run .#home-manager -- switch --flake .#default --impure -b hm-backup "$@"

echo "Done. Open a new shell, or run: exec bash -l"

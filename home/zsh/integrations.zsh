# Keeps $path deduplicated when this file is re-sourced.
typeset -U path PATH

# The tools below are installed outside Nix, per host, so each one is guarded: a
# host without it just skips the block.

# thefuck spawns a Python interpreter at startup (~300ms), so it is loaded only
# when actually installed. It is unmaintained upstream — pay-respects is the
# maintained drop-in if this ever stops working.
if command -v thefuck >/dev/null 2>&1; then
  eval "$(thefuck --alias)"
fi

# kubectl's completion script is slow to generate, so cache it rather than
# regenerating on every shell. Delete the cache file after a kubectl upgrade.
if command -v kubectl >/dev/null 2>&1; then
  _kubectl_comp="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/kubectl-completion.zsh"
  [[ -d "${_kubectl_comp:h}" ]] || mkdir -p "${_kubectl_comp:h}"
  [[ -s "$_kubectl_comp" ]] || kubectl completion zsh > "$_kubectl_comp"
  source "$_kubectl_comp"
  unset _kubectl_comp
fi

# Desktop-only package: an unguarded alias would mask any real `code` on PATH.
if command -v codium >/dev/null 2>&1; then
  alias code='codium'
fi

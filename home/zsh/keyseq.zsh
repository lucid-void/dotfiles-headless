# only reliable way to fix a "this key does nothing" report, since the answer
# depends on the terminal, on tmux, and on whether the terminal is in
# application cursor mode. Paste the output straight into a bindkey line.
keyseq() {
  local k seq
  print -n "Press one key: "
  read -rsk 1 k || return
  seq=$k
  # The rest of an escape sequence arrives in the same burst; 50ms is long
  # enough to catch it and short enough not to wait on a lone Esc.
  while read -rsk 1 -t 0.05 k; do seq+=$k; done
  print -r -- "${(V)seq}"
}

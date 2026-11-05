# Refresh font cache (fonts live under ~/.local/share/fonts — no sudo needed)
update_fonts() {
  fc-cache -fv
}

# Rebuild quickshell against the Qt it will actually run under. quickshell links
# Qt's *private* API, which carries no ABI guarantee even between patch releases,
# so a qt6-base bump leaves the installed binary aborting on an undefined symbol
# and Hyprland comes up bare — cursor on a blank colour, no bar, no wallpaper, no
# themed launcher. pacman's quickshell-check.hook reports it at upgrade time, but
# it scrolls past in the transaction output. The PKGBUILD pins its commit, so this
# recompiles the quickshell you already had rather than pulling a newer one.
# Flags: -s reinstalls the makedeps (cli11 and vulkan-headers get reaped as
# orphans between rebuilds), -i installs the result, -f overwrites the stale
# package file. Restart the shell afterwards with Ctrl+Super+R.
rebuild-qt() {
  local builddir=~/.cache/dots-hyprland/sdata/dist-arch/illogical-impulse-quickshell-git
  if [[ ! -f $builddir/PKGBUILD ]]; then
    print -u2 "rebuild-qt: no PKGBUILD under $builddir"
    print -u2 "rebuild-qt: re-run the dots-hyprland installer to restore the build tree"
    return 1
  fi
  # Subshell so a failed build does not strand the caller in the build directory.
  ( cd $builddir && makepkg -sif "$@" )
}

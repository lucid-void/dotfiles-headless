{ ... }:
{
  programs.fastfetch = {
    enable = true;
    settings = {
      logo.padding.top = 1;
      display.separator = "  ";
      modules = [
        "title"
        "separator"
        "os"
        "host"
        "kernel"
        "uptime"
        "packages"
        "shell"
        "cpu"
        "gpu"
        "memory"
        "swap"
        "disk"
        "localip"
        "break"
        "colors"
      ];
    };
  };
}

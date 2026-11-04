{ ... }:
{
  programs.fastfetch = {
    enable = true;
    settings = {
      logo.padding = {
        top = 1;
        left = 2;
        right = 4;
      };
      display.separator = " ➜  ";
      modules = [
        "break"
        { type = "os"; key = "OS   "; keyColor = "#ed8796"; }
        { type = "kernel"; key = " ├  "; keyColor = "#ed8796"; }
        { type = "packages"; key = " ├ 󰏖 "; keyColor = "#ed8796"; }
        { type = "shell"; key = " └  "; keyColor = "#ed8796"; }
        "break"
        { type = "host"; key = "PC   "; keyColor = "#eed49f"; }
        { type = "cpu"; key = " ├  "; keyColor = "#eed49f"; }
        { type = "gpu"; key = " ├ 󰢮 "; keyColor = "#eed49f"; }
        { type = "memory"; key = " ├  "; keyColor = "#eed49f"; }
        { type = "swap"; key = " ├ 󰓡 "; keyColor = "#eed49f"; }
        { type = "disk"; key = " ├ 󰋊 "; keyColor = "#eed49f"; }
        { type = "localip"; key = " └  "; keyColor = "#eed49f"; }
        "break"
      ];
    };
  };
}

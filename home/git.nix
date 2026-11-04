{ ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "lucid-void";
        email = "74971817+lucid-void@users.noreply.github.com";
      };
      core = {
        editor = "nvim";
        autocrlf = "input";
      };
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
      rebase.autoStash = true;
      diff = {
        tool = "nvimdiff";
        colorMoved = "default";
      };
      merge = {
        tool = "nvimdiff";
        conflictStyle = "zdiff3";
      };
      color.ui = "auto";
      alias = {
        st = "status -sb";
        lg = "log --oneline --graph --decorate --all";
        lga = "log --oneline --graph --decorate --all --author-date-order";
        co = "checkout";
        br = "branch";
        cp = "cherry-pick";
        undo = "reset --soft HEAD~1";
      };
    };
  };

  # delta reads bat's theme cache, so this is the theme from tools.nix.
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      line-numbers = true;
      syntax-theme = "Catppuccin Macchiato";
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    # Machine-specific hosts, keys and overrides stay out of the repo.
    includes = [ "~/.ssh/config.private" ];
    matchBlocks."*" = {
      serverAliveInterval = 60;
      serverAliveCountMax = 3;
      addKeysToAgent = "yes";
      identityFile = "~/.ssh/id_ed25519";
      # Remote hosts rarely have kitty/ghostty terminfo. TERM is exempt from AcceptEnv.
      setEnv.TERM = "xterm-256color";
    };
  };
}

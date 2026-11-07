{ lib, pkgs, ... }:
let
  # nixpkgs has the wrong node_modules hash for opencode 2.2.5, so it fails to
  # build. Only applies to that version; delete once nixpkgs has moved past it.
  opencode =
    if pkgs.opencode.version == "2.2.5" then
      pkgs.opencode.overrideAttrs (old: {
        node_modules = old.node_modules.overrideAttrs {
          outputHash = "sha256-prx9dX7kUvs/E3zopkaPk5LXh3xJAy5sZeum/W8L7cA=";
        };
      })
    else
      pkgs.opencode;

  # `#none` / `#thinking` on a local model. opencode only builds reasoning
  # variants for openai-compatible servers from `reasoning_effort`, which Qwen,
  # GLM and Gemma chat templates ignore; they read `enable_thinking`. Honoured
  # by vLLM, SGLang and llama.cpp.
  thinking = enabled: { body.chat_template_kwargs.enable_thinking = enabled; };
  localModel = id: {
    name = id;
    variants = [
      ({ id = "none"; } // thinking false)
      ({ id = "thinking"; } // thinking true)
    ];
  };
in
{
  programs.opencode = {
    enable = true;
    package = opencode;

    # opencode expands {env:VAR} when it reads the file, so each host picks its
    # models and endpoint at runtime without a rebuild. Defaults are below.
    settings = {
      model = "{env:OC_BUILD_MODEL}";

      agents = {
        # Primary: plan thinks, build carries the plan out through tool calls.
        plan.model = "{env:OC_THINK_MODEL}";
        build.model = "{env:OC_BUILD_MODEL}";

        # Subagents on the smaller model.
        general.model = "{env:OC_AGENT_MODEL}";
        explore.model = "{env:OC_FAST_MODEL}";
        fast = {
          mode = "subagent";
          model = "{env:OC_FAST_MODEL}";
          description = "Deterministic steps with a fixed answer shape: extracting JSON to a schema, classifying or routing a request, applying a diff that has already been planned. Give it the complete input and the exact output format; it does not plan.";
        };

        # Hidden housekeeping.
        title.model = "{env:OC_FAST_MODEL}";
        summary.model = "{env:OC_FAST_MODEL}";
        compaction.model = "{env:OC_FAST_MODEL}";
      };

      # OpenAI-compatible server: LM Studio, Ollama, llama.cpp, vLLM, a LiteLLM proxy.
      providers.local = {
        name = "Local";
        package = "@opencode/ai/providers/openai-compatible";
        settings = {
          baseURL = "{env:OC_LOCAL_URL}";
          apiKey = "{env:OC_LOCAL_KEY}";
        };
        # When both are the same ID, the two entries are identical.
        models = {
          "{env:OC_LOCAL_MODEL}" = localModel "{env:OC_LOCAL_MODEL}";
          "{env:OC_LOCAL_SMALL_MODEL}" = localModel "{env:OC_LOCAL_SMALL_MODEL}";
        };
      };
    };
  };

  # Defaults, after ~/.zshrc.local (2100) so a host can set any of these there,
  # and the tiers follow a changed local model. Not OPENCODE_*: opencode reads
  # some of those itself (OPENCODE_API_KEY, OPENCODE_LOCAL).
  programs.zsh.initContent = lib.mkOrder 2200 ''
    export OC_LOCAL_URL="''${OC_LOCAL_URL:-http://localhost:1234/v1}"
    export OC_LOCAL_KEY="''${OC_LOCAL_KEY:-local}"
    export OC_LOCAL_MODEL="''${OC_LOCAL_MODEL:-qwen3.8-27b}"
    export OC_LOCAL_SMALL_MODEL="''${OC_LOCAL_SMALL_MODEL:-$OC_LOCAL_MODEL}"
    export OC_THINK_MODEL="''${OC_THINK_MODEL:-local/$OC_LOCAL_MODEL#thinking}"
    export OC_BUILD_MODEL="''${OC_BUILD_MODEL:-local/$OC_LOCAL_MODEL#none}"
    export OC_AGENT_MODEL="''${OC_AGENT_MODEL:-local/$OC_LOCAL_SMALL_MODEL}"
    export OC_FAST_MODEL="''${OC_FAST_MODEL:-local/$OC_LOCAL_SMALL_MODEL#none}"
  '';
}

{
  description = "M's dotfiles — portable shell environment for Arch/Ubuntu nodes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;

      mkHome =
        {
          system,
          username,
          homeDirectory,
        }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [
            ./home
            { home = { inherit username homeDirectory; }; }
          ];
        };
    in
    {
      homeConfigurations = {
        # Works for whichever user runs it (root included).
        # Impure because it reads $USER, $HOME and the host system:
        #   home-manager switch --flake .#default --impure
        default = mkHome {
          system = builtins.currentSystem;
          username = builtins.getEnv "USER";
          homeDirectory = builtins.getEnv "HOME";
        };
      };

      # Pinned home-manager CLI, so `nix run .#home-manager` matches flake.lock.
      packages = forAllSystems (system: {
        home-manager = home-manager.packages.${system}.home-manager;
        default = home-manager.packages.${system}.home-manager;
      });

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
    };
}

{
  description = "Nix Flake for configuring my editors";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    systems.url = "github:nix-systems/default";

    # Emacs Twist - for building Emacs configurations
    twist = {
      url = "github:emacs-twist/twist.nix";
    };
    org-babel = {
      url = "github:emacs-twist/org-babel";
    };

    # Package registries for Twist
    melpa = {
      url = "github:melpa/melpa";
      flake = false;
    };
    gnu-elpa = {
      # Use GitHub mirror for better availability
      url = "github:elpa-mirrors/elpa";
      flake = false;
    };
    nongnu-elpa = {
      # Use GitHub mirror for better availability
      url = "github:elpa-mirrors/nongnu";
      flake = false;
    };

    # Keep emacs-overlay for potential fallback use
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NixCats for Neovim configuration
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
    "plugins-inlay-hints" = {
      url = "github:MysticalDevil/inlay-hints.nvim";
      flake = false;
    };
    "plugins-compile-nvim" = {
      url = "github:pohlrabi404/compile.nvim";
      flake = false;
    };

  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./args.nix
        ./nvim
        ./emacs
      ];
    };

}

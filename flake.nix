{
  description = "Nix Flake for configuring my editors";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # nixpkgs-test.url = "github:nixos/nixpkgs/0d0f425671a7f18c70baa48914f8c1dd2ffd0b49";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    systems.url = "github:nix-systems/default";

    # Emacs overlay - provides up-to-date Emacs builds and packages
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # org-babel overlay for tangling org files to elisp
    org-babel = {
      url = "github:emacs-twist/org-babel";
    };

    # Nix Wrapper modules for wrapping editor config
    nix-wrapper-modules = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
    };

    # Neovim plugins not in nixpkgs
    "plugins-compile-nvim" = {
      url = "github:pohlrabi404/compile.nvim";
      flake = false;
    };

    "plugins-tiny-code-action-nvim" = {
      url = "github:rachartier/tiny-code-action.nvim";
      flake = false;
    };

    # Emacs packages not in nixpkgs
    "emacs-swift-development" = {
      url = "github:konrad1977/swift-development";
      flake = false;
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./args.nix
        ./formatter.nix
        ./nvim
        ./emacs
      ];
    };
}

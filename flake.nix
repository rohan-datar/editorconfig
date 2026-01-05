{
  description = "Nix Flake for configuring my editors";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

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

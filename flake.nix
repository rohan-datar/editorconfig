{
  description = "Nix Flake for configuring my editors";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    systems.url = "github:nix-systems/default";

    # Second nixpkgs used to source emacsPackages.ghostel when testing
    # upgrades (see the ghostel block in emacs/overlay.nix).
    #
    # To test a nixpkgs PR or commit, repoint this input - no file edits needed:
    #   nix flake lock --override-input nixpkgs-test github:NixOS/nixpkgs/refs/pull/<N>/head
    #   nix flake lock --override-input nixpkgs-test github:NixOS/nixpkgs/<commit-sha>
    # And to return to stock unstable:
    #   nix flake lock --update-input nixpkgs-test
    nixpkgs-test.url = "github:nixos/nixpkgs/nixpkgs-unstable";

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
      url = "github:nix-community/nix-wrapper-modules";
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

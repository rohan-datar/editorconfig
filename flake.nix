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

    # Neovim plugins not in nixpkgs
    "plugins-compile-nvim" = {
      url = "github:pohlrabi404/compile.nvim";
      flake = false;
    };
    # Pin nvim-treesitter-textobjects main branch to bypass nixpkgs require check issue
    "plugins-nvim-treesitter-textobjects" = {
      url = "github:nvim-treesitter/nvim-treesitter-textobjects/main";
      flake = false;
    };

    # Emacs packages not in nixpkgs
    "emacs-ws-butler" = {
      url = "github:lewang/ws-butler";
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

      # Combine homeModules from different sources
      flake.homeModules = {
        nixCats = inputs.nixCats.utils.mkHomeModules {
          inherit (inputs) nixpkgs;
          inherit (inputs.nixCats) utils;
          luaPath = ./nvim;
          categoryDefinitions = import ./nvim/categories.nix inputs;
          packageDefinitions = import ./nvim/packages.nix inputs;
          dependencyOverlays = [
            (inputs.nixCats.utils.standardPluginOverlay inputs)
          ];
        };
        rdmacs = import ./emacs/home-module.nix;
      };

      flake.nixosModules = {
        nixCats = inputs.nixCats.utils.mkNixosModules {
          inherit (inputs) nixpkgs;
          inherit (inputs.nixCats) utils;
          luaPath = ./nvim;
          categoryDefinitions = import ./nvim/categories.nix inputs;
          packageDefinitions = import ./nvim/packages.nix inputs;
          dependencyOverlays = [
            (inputs.nixCats.utils.standardPluginOverlay inputs)
          ];
        };
      };
    };

}

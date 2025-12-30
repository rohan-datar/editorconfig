{ inputs, ... }:
{
  perSystem =
    {
      pkgs,
      system,
      ...
    }:
    let
      # Tangle the org config to an elisp file using the overlay function
      initFile = pkgs.tangleOrgBabelFile "init.el" ./emacs.org {
        languages = [
          "emacs-lisp"
          "elisp"
        ];
      };

      # Package registries for finding packages
      registries = [
        # GNU ELPA
        {
          name = "gnu";
          type = "elpa";
          path = inputs.gnu-elpa.outPath + "/elpa-packages";
          auto-sync-only = true;
        }
        # MELPA
        {
          name = "melpa";
          type = "melpa";
          path = inputs.melpa.outPath + "/recipes";
        }
        # NonGNU ELPA
        {
          type = "elpa";
          path = inputs.nongnu-elpa.outPath + "/elpa-packages";
        }
        # Archive fallbacks
        {
          type = "archive";
          url = "https://elpa.gnu.org/packages/";
        }
        {
          type = "archive";
          url = "https://elpa.nongnu.org/nongnu/";
        }
      ];

      # Explicitly list all packages from your config.org
      # This avoids IFD (Import From Derivation) by not parsing the init file at eval time
      # Update this list when you add/remove packages from config.org
      allPackages = [
        # Evil mode
        "evil"
        "evil-collection"
        "evil-surround"
        "evil-matchit"

        # Keybindings
        "general"

        # Appearance
        "catppuccin-theme"
        "doom-modeline"
        "nerd-icons"
        "nerd-icons-dired"
        "nerd-icons-ibuffer"
        "indent-guide"

        # Development
        "projectile"
        "sideline"
        "sideline-flymake"
        "yasnippet"
        "yasnippet-snippets"
        "eldoc-box"

        # Language modes
        "nix-mode"
        "lua-mode"
        "rust-mode"
        "dotenv-mode"
        "web-mode"

        # Terminal
        "eat"

        # Version Control
        "transient"
        "magit"
        "diff-hl"

        # Completion
        "corfu"
        "nerd-icons-corfu"
        "cape"
        "orderless"
        "vertico"
        "marginalia"
        "nerd-icons-completion"

        # Org mode
        "toc-org"
        "org-superstar"

        # Other packages
        "consult"
        "helpful"
        "diminish"
        "rainbow-delimiters"
        "ws-butler"
        "neotree"
      ];

      # Build the Emacs environment with twist library API
      rdmacs =
        (inputs.twist.lib.makeEnv {
          inherit pkgs;

          # Use emacs-pgtk for native Wayland support
          emacsPackage = pkgs.emacs-pgtk;

          # The tangled init file(s)
          initFiles = [ initFile ];

          # Lock directory for reproducible builds
          lockDir = ./lock;

          # Package registries
          inherit registries;

          # Don't try to parse init files - we specify packages explicitly
          # This avoids IFD
          initReader = _file: {
            elispPackages = [ ];
            systemPackages = [ ];
          };

          # Explicitly list all packages
          extraPackages = allPackages;

          # Don't native compile ahead of time for faster builds during iteration
          nativeCompileAheadDefault = false;
        }).overrideScope
          (
            self: super: {
              # Override specific packages if needed
              elispPackages = super.elispPackages.overrideScope (
                eself: esuper: {
                  # Example: if a package needs special handling
                  # vterm = esuper.vterm.overrideAttrs (old: { ... });
                }
              );
            }
          );

      # Test wrapper that runs in an isolated environment
      rdmacs-test = pkgs.writeShellScriptBin "rdmacs-test" ''
        # Create isolated home directory for testing
        TEST_HOME="''${XDG_RUNTIME_DIR:-/tmp}/rdmacs-test-$$"
        mkdir -p "$TEST_HOME/.emacs.d"

        # Copy init file to the temp home
        cp ${initFile} "$TEST_HOME/.emacs.d/init.el"

        # Clean up on exit
        trap "rm -rf $TEST_HOME" EXIT

        # Run Emacs with isolated home
        HOME="$TEST_HOME" exec ${rdmacs}/bin/emacs "$@"
      '';

    in
    {
      packages = {
        inherit rdmacs rdmacs-test;
      };
      apps = {
        rdmacs = {
          type = "app";
          program = "${rdmacs}/bin/emacs";
          meta.description = "Emacs with packages built by twist.nix";
        };
        rdmacs-test = {
          type = "app";
          program = "${rdmacs-test}/bin/rdmacs-test";
          meta.description = "Emacs in isolated environment for testing";
        };
      };
    };
}

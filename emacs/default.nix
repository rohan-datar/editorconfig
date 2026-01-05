{
  perSystem =
    {
      pkgs,
      system,
      ...
    }:
    let
      # Tangle the org config to an elisp file
      # org-babel overlay provides tangleOrgBabelFile
      initFile = pkgs.tangleOrgBabelFile "init.el" ./emacs.org {
        languages = [
          "emacs-lisp"
          "elisp"
        ];
      };

      # Override ws-butler to fetch from GitHub instead of savannah.gnu.org
      # Workaround for https://github.com/nix-community/emacs-overlay/issues/499
      ws-butler-github = pkgs.emacs-pgtk.pkgs.trivialBuild {
        pname = "ws-butler";
        version = "20250613";
        src = pkgs.fetchFromGitHub {
          owner = "lewang";
          repo = "ws-butler";
          rev = "67c49cfdf5a5a9f28792c500c8eb0017cfe74a3a";
          hash = "sha256-maOhnDkG3GibrbI1EuPRY+Ej4AZJgbFheu6lC72vZ4w=";
        };
      };

      # Build Emacs with packages using emacs-overlay's emacsWithPackages
      rdmacs = pkgs.emacs-pgtk.pkgs.withPackages (
        epkgs: with epkgs; [
          # Evil mode
          evil
          evil-collection
          evil-surround
          evil-matchit

          # Keybindings
          general

          # Appearance
          catppuccin-theme
          doom-modeline
          nerd-icons
          nerd-icons-dired
          nerd-icons-ibuffer
          indent-guide

          # Development
          projectile
          sideline
          sideline-flymake
          yasnippet
          yasnippet-snippets
          eldoc-box

          # Language modes
          nix-mode
          lua-mode
          rust-mode
          dotenv-mode
          web-mode
          nix-ts-mode

          # Tree-sitter grammars (for Emacs 29+ built-in tree-sitter)
          # Exclude broken grammars (tree-sitter-razor)
          (treesit-grammars.with-grammars (
            grammars: builtins.filter (g: g.pname or "" != "tree-sitter-razor") (builtins.attrValues grammars)
          ))

          # Terminal
          eat

          # Version Control
          transient
          magit
          diff-hl

          # Completion
          corfu
          nerd-icons-corfu
          cape
          orderless
          vertico
          marginalia
          nerd-icons-completion

          # Org mode
          toc-org
          org-superstar

          # Other packages
          consult
          helpful
          diminish
          rainbow-delimiters
          ws-butler-github
          neotree
        ]
      );

      # Create an init directory with our tangled config
      initDir = pkgs.runCommand "rdmacs-init-dir" { } ''
        mkdir -p $out
        cp ${initFile} $out/init.el
      '';

      # Wrapper suitable for services.emacs (provides bin/emacs with init dir)
      rdmacs-service = pkgs.symlinkJoin {
        name = "rdmacs-service";
        paths = [ rdmacs ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          rm $out/bin/emacs
          makeWrapper ${rdmacs}/bin/emacs $out/bin/emacs \
            --add-flags "--init-directory ${initDir}"
        '';
      };

      # Darwin app bundle with init-directory baked in (for Spotlight/GUI launch)
      rdmacs-darwin = pkgs.stdenv.mkDerivation {
        name = "rdmacs-darwin";
        dontUnpack = true;
        nativeBuildInputs = [ pkgs.makeWrapper ];
        buildPhase = ''
          mkdir -p $out/Applications
          mkdir -p $out/bin

          # Copy the Emacs.app structure
          cp -r ${rdmacs}/Applications/Emacs.app $out/Applications/

          # Make the app bundle writable so we can modify the launcher
          chmod -R u+w $out/Applications/Emacs.app

          # Replace the Emacs binary with a wrapper script
          rm $out/Applications/Emacs.app/Contents/MacOS/Emacs
          makeWrapper ${rdmacs}/bin/emacs $out/Applications/Emacs.app/Contents/MacOS/Emacs \
            --add-flags "--init-directory ${initDir}"

          # Also provide wrapped bin/emacs for CLI use
          makeWrapper ${rdmacs}/bin/emacs $out/bin/emacs \
            --add-flags "--init-directory ${initDir}"
        '';
        installPhase = "true";
      };

      # Test wrapper for live config editing
      # Tangles your local emacs.org on the fly, so you can iterate without rebuilding
      # Run from the flake directory, or set RDMACS_CONFIG to your emacs.org path
      rdmacs-test = pkgs.writeShellScriptBin "rdmacs-test" ''
        EMACS_ORG="''${RDMACS_CONFIG:-./emacs/emacs.org}"

        if [ ! -f "$EMACS_ORG" ]; then
          echo "Error: Cannot find emacs.org at $EMACS_ORG"
          echo "Run from the flake directory or set RDMACS_CONFIG to your emacs.org path"
          exit 1
        fi

        # Create temp directory for tangled output
        TANGLE_DIR="$(mktemp -d)"
        trap "rm -rf $TANGLE_DIR" EXIT

        # Copy org file to temp dir so tangle output goes there
        cp "$EMACS_ORG" "$TANGLE_DIR/emacs.org"

        # Tangle org file to elisp on the fly
        ${rdmacs}/bin/emacs --batch \
          --eval "(require 'org)" \
          --eval "(org-babel-tangle-file \"$TANGLE_DIR/emacs.org\" nil \"emacs-lisp\")"

        # Run Emacs with tangled config as init directory
        # (emacs.el gets renamed to init.el for Emacs to find it)
        mv "$TANGLE_DIR/emacs.el" "$TANGLE_DIR/init.el"
        exec ${rdmacs}/bin/emacs --init-directory "$TANGLE_DIR" "$@"
      '';

    in
    {
      packages = {
        inherit rdmacs rdmacs-test rdmacs-service rdmacs-darwin;
      };
      apps = {
        rdmacs-test = {
          type = "app";
          program = "${rdmacs-test}/bin/rdmacs-test";
          meta.description = "Emacs with live-tangling for config iteration";
        };
      };
    };
}

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

      # Emacs packages and runtime dependencies imported from separate file
      packages = import ./packages.nix { inherit pkgs; };

      # Build Emacs with packages using emacs-overlay's emacsWithPackages
      rdmacs = pkgs.emacs-pgtk.pkgs.withPackages packages.emacsPackages;

      # Runtime deps path for wrappers
      runtimePath = pkgs.lib.makeBinPath packages.runtimeDeps;

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
            --add-flags "--init-directory ${initDir}" \
            --prefix PATH : ${runtimePath}
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
            --add-flags "--init-directory ${initDir}" \
            --prefix PATH : ${runtimePath}

          # Also provide wrapped bin/emacs for CLI use
          makeWrapper ${rdmacs}/bin/emacs $out/bin/emacs \
            --add-flags "--init-directory ${initDir}" \
            --prefix PATH : ${runtimePath}
        '';
        installPhase = "true";
      };

      # Test wrapper for live config editing
      # Tangles your local emacs.org on the fly, so you can iterate without rebuilding
      # Run from the flake directory, or set RDMACS_CONFIG to your emacs.org path
      rdmacs-test = pkgs.writeShellScriptBin "rdmacs-test" ''
        export PATH="${runtimePath}:$PATH"

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

{
  perSystem =
    {
      pkgs,
      system,
      ...
    }:
    let
      inherit (pkgs.stdenv) isDarwin;

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
      rdmacs-unwrapped = pkgs.emacs-pgtk.pkgs.withPackages packages.emacsPackages;

      # Runtime deps path for wrappers
      runtimePath = pkgs.lib.makeBinPath packages.runtimeDeps;

      # Create an init directory with our tangled config
      initDir = pkgs.runCommand "rdmacs-init-dir" { } ''
        mkdir -p $out
        cp ${initFile} $out/init.el
      '';

      # Wrapped rdmacs with init-directory baked in
      # On Darwin, also creates Emacs.app and Emacsclient.app bundles
      rdmacs = pkgs.stdenv.mkDerivation {
        name = "rdmacs";
        dontUnpack = true;
        nativeBuildInputs = [ pkgs.makeWrapper ];
        buildPhase = ''
          mkdir -p $out/bin

          # Wrapped bin/emacs for CLI and daemon use
          makeWrapper ${rdmacs-unwrapped}/bin/emacs $out/bin/emacs \
            --add-flags "--init-directory ${initDir}" \
            --prefix PATH : ${runtimePath}

          # Wrapped bin/emacsclient that opens a new frame
          makeWrapper ${rdmacs-unwrapped}/bin/emacsclient $out/bin/emacsclient \
            --add-flags "-c"

          ${pkgs.lib.optionalString isDarwin ''
            mkdir -p $out/Applications

            # Copy and wrap Emacs.app
            cp -r ${rdmacs-unwrapped}/Applications/Emacs.app $out/Applications/
            chmod -R u+w $out/Applications/Emacs.app
            rm $out/Applications/Emacs.app/Contents/MacOS/Emacs
            makeWrapper ${rdmacs-unwrapped}/bin/emacs $out/Applications/Emacs.app/Contents/MacOS/Emacs \
              --add-flags "--init-directory ${initDir}" \
              --prefix PATH : ${runtimePath}

            # Create Emacsclient.app for Spotlight/Raycast
            mkdir -p $out/Applications/Emacsclient.app/Contents/MacOS
            mkdir -p $out/Applications/Emacsclient.app/Contents/Resources

            cp ${rdmacs-unwrapped}/Applications/Emacs.app/Contents/Resources/Emacs.icns \
              $out/Applications/Emacsclient.app/Contents/Resources/Emacsclient.icns

            cat > $out/Applications/Emacsclient.app/Contents/Info.plist <<EOF
            <?xml version="1.0" encoding="UTF-8"?>
            <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
            <plist version="1.0">
            <dict>
              <key>CFBundleExecutable</key>
              <string>Emacsclient</string>
              <key>CFBundleIconFile</key>
              <string>Emacsclient</string>
              <key>CFBundleIdentifier</key>
              <string>org.gnu.Emacsclient</string>
              <key>CFBundleName</key>
              <string>Emacsclient</string>
              <key>CFBundlePackageType</key>
              <string>APPL</string>
              <key>CFBundleVersion</key>
              <string>1.0</string>
            </dict>
            </plist>
            EOF

            makeWrapper ${rdmacs-unwrapped}/bin/emacsclient $out/Applications/Emacsclient.app/Contents/MacOS/Emacsclient \
              --add-flags "-c"
          ''}

          ${pkgs.lib.optionalString (!isDarwin) ''
            # Copy .desktop files and icons from base emacs for Linux launchers
            cp -r ${rdmacs-unwrapped}/share/applications $out/share/
            cp -r ${rdmacs-unwrapped}/share/icons $out/share/
          ''}
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
        ${rdmacs-unwrapped}/bin/emacs --batch \
          --eval "(require 'org)" \
          --eval "(org-babel-tangle-file \"$TANGLE_DIR/emacs.org\" nil \"emacs-lisp\")"

        # Run Emacs with tangled config as init directory
        # (emacs.el gets renamed to init.el for Emacs to find it)
        mv "$TANGLE_DIR/emacs.el" "$TANGLE_DIR/init.el"
        exec ${rdmacs-unwrapped}/bin/emacs --init-directory "$TANGLE_DIR" "$@"
      '';
    in
    {
      packages = {
        inherit
          rdmacs
          rdmacs-test
          ;
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

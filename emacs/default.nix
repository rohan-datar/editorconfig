{ inputs, ... }:
{
  flake.wrappers.rdmacs =
    {
      config,
      pkgs,
      wlib,
      lib,
      ...
    }:
    let
      inherit (pkgs.stdenv) isDarwin;
      packages = import ./packages.nix { inherit pkgs; };
      tangle = (pkgs.extend inputs.org-babel.overlays.default).tangleOrgBabelFile;

      # Tangle the org config to an elisp file
      # org-babel overlay provides tangleOrgBabelFile
      initFile = tangle "init.el" ./emacs.org {
        languages = [
          "emacs-lisp"
          "elisp"
        ];
      };
    in
    {
      imports = [ wlib.wrapperModules.emacs ];

      package = pkgs.emacs-pgtk;
      emacsPackages = packages.emacsPackages;
      configFile = "";
      earlyConfigFile = "";
      constructFiles.init.builder = ''
        mkdir -p "$(dirname "$2")"
        cp "${initFile}" "$2"
      '';
      constructFiles.early-init.builder = ''
        mkdir -p "$(dirname "$2")"
        cp "${./early-init.el}" "$2"
      '';
      extraPackages = packages.runtimeDeps;
      wrapperVariants.emacsclient = {
        exePath = "bin/emacsclient";
        mirror = false; # Don't inherit --init-directory from emacs (emacsclient doesn't support it)
        addFlag = [ "-c" ];
      };
      buildCommand.fixDarwinApp = lib.mkIf isDarwin {
        after = [
          "symlinkScript"
          "makeWrapper"
        ];
        data = ''
          if [ -d "$out/Applications/Emacs.app" ]; then
              rm "$out/Applications/Emacs.app/Contents/MacOS/Emacs"
              ln -s "$out/bin/emacs" "$out/Applications/Emacs.app/Contents/MacOS/Emacs"
          fi

          # Create Emacsclient.app for Spotlight/Raycast
          mkdir -p "$out/Applications/Emacsclient.app/Contents/MacOS"
          mkdir -p "$out/Applications/Emacsclient.app/Contents/Resources"

          # Reuse Emacs icon
          cp "$out/Applications/Emacs.app/Contents/Resources/Emacs.icns" \
             "$out/Applications/Emacsclient.app/Contents/Resources/Emacsclient.icns"

          # Minimal Info.plist via heredoc
          cat > "$out/Applications/Emacsclient.app/Contents/Info.plist" <<'PLIST'
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
          PLIST

          # Point binary at wrapped emacsclient
          ln -s "$out/bin/emacsclient" "$out/Applications/Emacsclient.app/Contents/MacOS/Emacsclient"
        '';
      };

    };

  perSystem =
    { pkgs, ... }:
    let
      # Emacs packages and runtime dependencies imported from separate file
      packages = import ./packages.nix { inherit pkgs; };

      runtimePath = pkgs.lib.makeBinPath packages.runtimeDeps;

      # Build Emacs with packages using emacs-overlay's emacsWithPackages
      rdmacs-unwrapped = pkgs.emacs-pgtk.pkgs.withPackages packages.emacsPackages;

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

        # Copy early-init.el alongside it so early initialization (UI chrome,
        # frame colors, GC tuning) runs the same way it does in the built package.
        EARLY_INIT="$(dirname "$EMACS_ORG")/early-init.el"
        if [ -f "$EARLY_INIT" ]; then
          cp "$EARLY_INIT" "$TANGLE_DIR/early-init.el"
        fi

        exec ${rdmacs-unwrapped}/bin/emacs --init-directory "$TANGLE_DIR" "$@"
      '';
    in
    {
      packages = {
        inherit
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

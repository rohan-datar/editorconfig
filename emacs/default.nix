{ inputs, ... }:
{
  perSystem =
    { pkgs, lib, ... }:
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

      rdmacs = inputs.nix-wrapper-modules.wrappers.emacs.wrap {
        inherit pkgs;
        imports = [
          ({ config, ... }: {
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
            # The wrapper module only auto-adds --init-directory when configFile or
            # earlyConfigFile is non-empty. We bypass those by writing the files via
            # constructFiles.*.builder, so we need to add the flag ourselves.
            flags."--init-directory" = dirOf config.constructFiles.init.path;
            runtimePkgs = packages.runtimeDeps;
            wrapperVariants.emacsclient = {
              exePath = "bin/emacsclient";
              # Don't inherit --init-directory from emacs (emacsclient doesn't support it).
              # We intentionally do NOT add `-c` here: the wrapped `bin/emacsclient`
              # should behave like a plain emacsclient on the CLI. The `-c -n` flags
              # for launching a new frame from the app bundle are handled by the
              # AppleScript in `Emacsclient.app` (see fixDarwinApp below).
              mirror = false;
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

                # Build Emacsclient.app as an AppleScript applet (like the
                # homebrew emacs-plus / Emacs_Client_For_OSX launchers).
                #
                # The previous version symlinked the executable directly at the
                # wrapped `emacsclient`. When launched as a GUI app bundle that
                # process hung around as its own Dock icon (permanently bouncing)
                # and registered as a separate app with tiling WMs.
                #
                # Instead, the applet is a background agent (LSUIElement = true):
                #   * it never shows up in the Dock or app switcher,
                #   * it just calls `emacsclient -c -n` via `do shell script`,
                #   * the new frame is created by the *already running* Emacs.app
                #     server, so it is owned by Emacs.app's Dock icon and is the
                #     only window your WM sees.
                EMACSCLIENT_APP="$out/Applications/Emacsclient.app"
                rm -rf "$EMACSCLIENT_APP"

                # NOTE: heredoc bodies and their closing delimiters below are
                # intentionally at column 0. bash only recognizes the closing
                # delimiter when it starts at the beginning of a line (leading
                # whitespace would make it part of the body and swallow the rest
                # of the build script). The body indentation does not matter to
                # AppleScript / XML.
                cat > "$TMPDIR/emacsclient.applescript" <<APPLESCRIPT
-- Emacsclient launcher (background agent, no Dock icon).
-- Opens a frame on the running Emacs server; if no server is up,
-- launches Emacs.app and retries for up to ~30s.

property emacsClientBin : "$out/bin/emacsclient"
property emacsApp : "$out/Applications/Emacs.app"

on openClient(argStr)
    try
        do shell script (quoted form of emacsClientBin & " -c -n" & argStr)
        return true
    on error
        return false
    end try
end openClient

on run argv
    set argStr to ""
    repeat with arg in argv
        set argStr to argStr & " " & quoted form of (arg as text)
    end repeat

    if openClient(argStr) then return

    -- No server running: start Emacs.app, then poll until it accepts connections.
    do shell script "open " & quoted form of emacsApp
    set waited to 0
    repeat while waited < 30
        delay 1
        set waited to waited + 1
        if openClient(argStr) then return
    end repeat
end run
APPLESCRIPT

                # Compile the script into an app bundle. osacompile ships with
                # macOS and is reachable at /usr/bin in the build environment.
                /usr/bin/osacompile -o "$EMACSCLIENT_APP" "$TMPDIR/emacsclient.applescript"

                # Reuse the Emacs icon for the applet (osacompile ships a generic
                # applet.icns; overwrite it so Spotlight/Raycast shows the Emacs icon).
                if [ -f "$out/Applications/Emacs.app/Contents/Resources/Emacs.icns" ]; then
                    cp "$out/Applications/Emacs.app/Contents/Resources/Emacs.icns" \
                       "$EMACSCLIENT_APP/Contents/Resources/applet.icns"
                fi

                # Rewrite Info.plist: claim our own identity and mark the bundle
                # as a background agent so it never enters the Dock / app switcher.
                # osacompile already created Contents/MacOS/applet and a default
                # plist referencing it; we keep the `applet` executable name and
                # just replace the plist.
                cat > "$EMACSCLIENT_APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key>
  <string>applet</string>
  <key>CFBundleIconFile</key>
  <string>applet</string>
  <key>CFBundleIdentifier</key>
  <string>org.gnu.Emacsclient</string>
  <key>CFBundleName</key>
  <string>Emacsclient</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleVersion</key>
  <string>1.0</string>
  <key>LSUIElement</key>
  <true/>
  <key>NSHighResolutionCapable</key>
  <true/>
</dict>
</plist>
PLIST
              '';
            };
          })
        ];
      };

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

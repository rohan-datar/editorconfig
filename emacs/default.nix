{ inputs, ... }:
{
  perSystem =
    { pkgs, lib, ... }:
    let
      inherit (pkgs.stdenv) isDarwin;
      packages = import ./packages.nix { inherit pkgs inputs; };
      # Tangle the org config to an elisp string at eval time (no IFD).
      # We pass the result directly to the wrapper's configFile option.
      tangleContent = inputs.org-babel.lib.tangleOrgBabel {
        languages = [
          "emacs-lisp"
          "elisp"
        ];
      } (builtins.readFile ./emacs.org);

      rdmacs = inputs.nix-wrapper-modules.wrappers.emacs.wrap {
        inherit pkgs;
        imports = [
          ({ config, ... }: {
            package = pkgs.emacs-pgtk;
            emacsPackages = packages.emacsPackages;
            # Set user-emacs-directory to a writable location so packages don't
            # try to write into the read-only Nix store init directory.
            userDirectory = "~/.cache/emacs";
            configFile = tangleContent;
            earlyConfigFile = builtins.readFile ./early-init.el;
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

                				# Build Emacsclient.app as an AppleScript applet.
                				# The AppleScript source lives in a separate file
                				# (./emacsclient-launcher.applescript) with @out@ placeholders
                				# that we substitute here, where the final $out store path is
                				# known. This keeps the launcher logic out of the Nix file.
                				EMACSCLIENT_APP="$out/Applications/Emacsclient.app"
                				rm -rf "$EMACSCLIENT_APP"

                				cp ${./emacsclient-launcher.applescript} "$TMPDIR/emacsclient.applescript"
                				substituteInPlace "$TMPDIR/emacsclient.applescript" --subst-var out

                				# Compile the script into an app bundle. osacompile ships with
                				# macOS and is reachable at /usr/bin in the build environment.
                				/usr/bin/osacompile -o "$EMACSCLIENT_APP" "$TMPDIR/emacsclient.applescript"

                				APPLET_EXE="$(basename "$(find "$EMACSCLIENT_APP/Contents/MacOS" -type f -print -quit)")"

                				# Reuse the Emacs icon for the applet. osacompile ships a generic
                				# applet/droplet icon at "$APPLET_EXE.icns"; overwrite it so
                				# Spotlight/Raycast shows the Emacs icon.
                				if [ -f "$out/Applications/Emacs.app/Contents/Resources/Emacs.icns" ]; then
                					cp "$out/Applications/Emacs.app/Contents/Resources/Emacs.icns" \
                						"$EMACSCLIENT_APP/Contents/Resources/''${APPLET_EXE}.icns"
                				fi

                				# Rewrite Info.plist: claim our own identity and mark the bundle
                				# as a background agent so it never enters the Dock / app switcher.
                				# The plist lives in ./emacsclient-info.plist with @APPLET_EXE@
                				# placeholders, substituted here once osacompile has produced the
                				# bundle and we know the executable name (applet vs droplet).
                				cp ${./emacsclient-info.plist} "$EMACSCLIENT_APP/Contents/Info.plist"
                				substituteInPlace "$EMACSCLIENT_APP/Contents/Info.plist" \
                					--replace "@APPLET_EXE@" "$APPLET_EXE"
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

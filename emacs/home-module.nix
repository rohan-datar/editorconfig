# Home-manager module for rdmacs
# This module sets up the init.el symlink and Darwin app alias
# The package is provided as an option, allowing users to pass
# inputs.editorconfig.packages.${system}.rdmacs
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    mkDefault
    types
    ;
  cfg = config.programs.rdmacs;
in
{
  options.programs.rdmacs = {
    enable = mkEnableOption "rdmacs - Rohan's Emacs configuration";

    package = mkOption {
      type = types.package;
      description = "The rdmacs package to use (from editorconfig flake)";
    };

    initFile = mkOption {
      type = types.path;
      description = "The init.el file to symlink (from editorconfig flake)";
    };

    installPackage = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to install the rdmacs package to home.packages.
        Set to false if using NixOS services.emacs which provides the package.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = mkIf cfg.installPackage [ cfg.package ];

    # Symlink the init.el to ~/.emacs.d/init.el
    home.file.".emacs.d/init.el".source = cfg.initFile;

    # Create early-init.el for faster startup
    home.file.".emacs.d/early-init.el".text = ''
      ;; -*- lexical-binding: t; -*-
      ;; Defer garbage collection during startup
      (setq gc-cons-threshold most-positive-fixnum)

      ;; Prevent package.el from loading packages before init
      (setq package-enable-at-startup nil)

      ;; Disable UI elements early for faster startup
      (push '(menu-bar-lines . 0) default-frame-alist)
      (push '(tool-bar-lines . 0) default-frame-alist)
      (push '(vertical-scroll-bars) default-frame-alist)

      ;; Disable native-comp warnings
      (setq native-comp-async-report-warnings-errors nil)
    '';

    # On Darwin, create an app wrapper that points to the rdmacs binary
    home.activation = mkIf pkgs.stdenv.isDarwin {
      copyEmacsApp = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        APP_DIR="$HOME/Applications/Nix Apps"
        mkdir -p "$APP_DIR"

        # Get the underlying Emacs.app from emacs-pgtk
        EMACS_APP="${pkgs.emacs-pgtk}/Applications/Emacs.app"

        if [ -d "$EMACS_APP" ]; then
          # Remove old app if it exists
          rm -rf "$APP_DIR/Emacs.app"

          # Create a wrapper app that uses our rdmacs binary
          mkdir -p "$APP_DIR/Emacs.app/Contents/MacOS"
          mkdir -p "$APP_DIR/Emacs.app/Contents/Resources"

          # Copy Info.plist and resources from original
          cp "$EMACS_APP/Contents/Info.plist" "$APP_DIR/Emacs.app/Contents/"
          cp -r "$EMACS_APP/Contents/Resources/"* "$APP_DIR/Emacs.app/Contents/Resources/" 2>/dev/null || true

          # Create a wrapper script that calls our rdmacs
          cat > "$APP_DIR/Emacs.app/Contents/MacOS/Emacs" << 'WRAPPER'
#!/bin/bash
exec "${cfg.package}/bin/emacs" "$@"
WRAPPER
          chmod +x "$APP_DIR/Emacs.app/Contents/MacOS/Emacs"

          # Touch the app to update Spotlight index
          touch "$APP_DIR/Emacs.app"
        fi
      '';
    };
  };
}

{
  perSystem =
    {
      pkgs,
      config,
      ...
    }:
    let
      # Use emacs-pgtk for native Wayland support
      rdmacs = pkgs.emacsWithPackagesFromUsePackage {
        package = pkgs.emacs-pgtk;
        config = ./emacs.org;
        defaultInitFile = false;
        alwaysEnsure = true;
        alwaysTangle = true;
        extraEmacsPackages = epkgs: [
          epkgs.cask
          pkgs.shellcheck
          pkgs.rust-analyzer
          pkgs.nil
        ];
      };

      # Store the config path
      emacsConfig = ./emacs.org;

      # Wrapper script that loads config from the source directory
      rdmacs-test = pkgs.writeShellScriptBin "rdmacs-test" ''
        # Use a separate user-emacs-directory to avoid conflicts
        export HOME="''${XDG_RUNTIME_DIR:-/tmp}/rdmacs-test-$$"
        mkdir -p "$HOME/.emacs.d"

        # Create a minimal init that loads the org config
        # We specify a writable output path for the tangled file
        cat > "$HOME/.emacs.d/init.el" << EOF
        (require 'org)
        (defvar rdmacs-config-org "${emacsConfig}")
        (defvar rdmacs-config-el "$HOME/.emacs.d/config.el")
        (org-babel-tangle-file rdmacs-config-org rdmacs-config-el)
        (load-file rdmacs-config-el)
        EOF

        exec ${rdmacs}/bin/emacs "$@"
      '';
    in
    {
      packages = {
        rdmacs = rdmacs;
        rdmacs-test = rdmacs-test;
      };

      apps = {
        rdmacs = {
          type = "app";
          program = "${rdmacs}/bin/emacs";
          meta.description = "Emacs with packages from use-package config";
        };
        rdmacs-test = {
          type = "app";
          program = "${rdmacs-test}/bin/rdmacs-test";
          meta.description = "Emacs with live-editable config from source directory";
        };
      };
    };
}

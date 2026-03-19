# Overlay to automatically convert flake inputs starting with "emacs-" to Emacs packages
# Similar to NixCats' standardPluginOverlay for neovimPlugins
inputs: final: prev:
let
  inherit (final) emacs-pgtk;
  epkgs = emacs-pgtk.pkgs;

  # Define dependencies for packages that need them
  # This is similar to how you'd specify dependencies in a MELPA recipe
  packageDeps = {
    # Add packages that need dependencies here
    # doom-dashboard = with epkgs; [
    #   dashboard
    #   nerd-icons
    # ];

    swift-development = with epkgs; [
      # Built-in packages are automatically available, only need MELPA packages
      nerd-icons
      request
    ];
  };

  # Packages that should skip byte-compilation
  skipCompilation = [
  ];

  # Filter inputs that start with "emacs-" and have flake = false
  emacsInputs = builtins.filter (
    name: builtins.match "emacs-.*" name != null && inputs.${name} ? outPath
  ) (builtins.attrNames inputs);

  # Convert each input to an Emacs package using trivialBuild
  buildEmacsPackage =
    name:
    let
      # Remove "emacs-" prefix to get the package name
      pkgName = builtins.substring 6 (builtins.stringLength name) name;
      shouldSkipCompile = builtins.elem pkgName skipCompilation;
    in
    {
      name = pkgName;
      value =
        final.emacs-pgtk.pkgs.trivialBuild {
          pname = pkgName;
          version = "unstable-${inputs.${name}.lastModifiedDate or "unknown"}";
          src = inputs.${name};
          packageRequires = packageDeps.${pkgName} or [ ];
        }
        // (
          if shouldSkipCompile then
            {
              buildPhase = ''
                				runHook preBuild
                				runHook postBuild
              '';
            }
          else
            { }
        );
    };

  # Build all Emacs packages from inputs
  customEmacsPackages = builtins.listToAttrs (map buildEmacsPackage emacsInputs);
in
{
  # Add a custom package set similar to neovimPlugins
  inherit customEmacsPackages;
}

# Overlay to automatically convert flake inputs starting with "emacs-" to Emacs packages
# Similar to NixCats' standardPluginOverlay for neovimPlugins
inputs: final: prev:
let
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
    in
    {
      name = pkgName;
      value = final.emacs-pgtk.pkgs.trivialBuild {
        pname = pkgName;
        version = "unstable-${inputs.${name}.lastModifiedDate or "unknown"}";
        src = inputs.${name};
      };
    };

  # Build all Emacs packages from inputs
  customEmacsPackages = builtins.listToAttrs (map buildEmacsPackage emacsInputs);
in
{
  # Add a custom package set similar to neovimPlugins
  inherit customEmacsPackages;
}

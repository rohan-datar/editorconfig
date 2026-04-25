# set some config for nixpkgs
{ inputs, ... }:
{
  # set the output systems for this flake
  systems = import inputs.systems;

  perSystem =
    { system, ... }:
    {
      # this is what controls how packages in the flake are built
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          allowUnsupportedSystem = true;
        };
        overlays = [
          # emacs-overlay is intentionally NOT applied: in recent revs it
          # overrides pkgs.tree-sitter to 0.26.x, which rejects bare `#match`
          # predicates that Emacs 30.2's bundled *-ts-modes still emit. The
          # melpa-package version delta vs. nixpkgs is small (days to weeks)
          # and not worth the broken rust-ts-mode font-lock.
          # See: https://github.com/NixOS/nixpkgs/issues/513404
          inputs.org-babel.overlays.default
          # Custom overlay to convert emacs-* inputs to packages
          (import "${inputs.self}/emacs/overlay.nix" inputs)
        ];
      };
    };
}

{
  self,
  inputs,
  ...
}:
let
  inherit (inputs) nixpkgs;
  inherit (inputs.nixCats) utils;

  luaPath = ./.;
  dependencyOverlays = [
    (utils.standardPluginOverlay inputs)
  ];

  categoryDefinitions = import ./categories.nix inputs;
  packageDefinitions = import ./packages.nix inputs;
in
{

  perSystem =
    {
      pkgs,
      system,
      ...
    }:
    let
      build = utils.baseBuilder luaPath {
        inherit nixpkgs system dependencyOverlays;
      } categoryDefinitions packageDefinitions;
    in
    {
      packages = {
        nvim-full = build "full";
        nvim-minimal = build "minimal";
        nvim-test = build "test";
        default = build "full";
      };

      apps = {
        nvim-full = {
          type = "app";
          program = "${build "full"}/bin/nvim";
          meta.description = "full nvim configuration";
        };
        nvim-minimal = {
          type = "app";
          program = "${build "minimal"}/bin/nvim";
          meta.description = "minimal nvim configuration";
        };
        nvim-test = {
          type = "app";
          program = "${build "test"}/bin/nvim-test";
          meta.description = "full nvim configuration with lua configuration that can be live edited and sourced";
        };
      };
    };

  flake = {
    homeModules.nixCats = utils.mkHomeModules {
      inherit
        nixpkgs
        utils
        luaPath
        categoryDefinitions
        packageDefinitions
        dependencyOverlays
        ;
    };
    nixosModules.nixCats = utils.mkNixosModules {
      inherit
        nixpkgs
        utils
        luaPath
        categoryDefinitions
        packageDefinitions
        dependencyOverlays
        ;
    };
  };
}

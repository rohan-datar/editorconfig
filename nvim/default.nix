{
  inputs,
  ...
}:
{
  flake.wrappers = {
    nvim-full =
      {
        config,
        pkgs,
        wlib,
        lib,
        ...
      }:
      {

        imports = [
          wlib.wrapperModules.neovim
          (import ./specs.nix inputs)
        ];
        settings = {
          config_directory = "${inputs.self}/nvim";
          aliases = [
            "rdvim"
            "vim"
          ];
        };
      };
    nvim-minimal =
      {
        config,
        pkgs,
        wlib,
        lib,
        ...
      }:
      {

        imports = [
          wlib.wrapperModules.neovim
          (import ./specs.nix inputs)
        ];
        profile = "minimal";
        settings = {
          config_directory = "${inputs.self}/nvim";
          aliases = [
            "rdvim"
            "vim"
          ];
        };
      };
    nvim-test =
      {
        config,
        pkgs,
        wlib,
        lib,
        ...
      }:
      {

        imports = [
          wlib.wrapperModules.neovim
          (import ./specs.nix inputs)
        ];
        settings = {
          block_normal_config = false;
          config_directory = lib.generators.mkLuaInline ''vim.fn.stdpath("config")'';
          aliases = [
            "nvim-test"
            "rdvim-test"
            "vim-test"
          ];
        };
      };
  };
}

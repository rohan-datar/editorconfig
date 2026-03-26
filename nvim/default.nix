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
            "nvim"
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
        settings = {
          config_directory = "${inputs.self}/nvim";
          aliases = [
            "nvim"
            "rdvim"
            "vim"
          ];
        };
        specs = {
          snippets.enable = false;
          lsp.enable = false;
          ai.enable = false;
          ui.enable = false;
          debuggers.enable = false;
          extras.enable = false;
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

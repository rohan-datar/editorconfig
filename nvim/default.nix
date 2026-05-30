{
  inputs,
  ...
}:
{
  perSystem =
    { pkgs, lib, ... }:
    let
      mkNvim = profile: settings:
        inputs.nix-wrapper-modules.wrappers.neovim.wrap {
          inherit pkgs profile settings;
          imports = [ (import ./specs.nix inputs) ];
        };
    in
    {
      packages = {
        nvim-full = mkNvim "full" {
          config_directory = "${inputs.self}/nvim";
          aliases = [
            "rdvim"
            "vim"
          ];
        };

        nvim-minimal = mkNvim "minimal" {
          config_directory = "${inputs.self}/nvim";
          aliases = [
            "rdvim"
            "vim"
          ];
        };

        nvim-test = mkNvim "test" {
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

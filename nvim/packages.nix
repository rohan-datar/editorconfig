inputs:
let
  inherit (inputs.nixCats) utils;
in
{
  full =
    { pkgs, ... }:
    {
      settings = {
        wrapRc = true;
        aliases = [
          "nvim"
          "rdvim"
          "vim"
        ];
      };

      categories = {
        core = true;
        editing = true;
        extra = true;
        treesitter = true;
        git = true;
        snippets = true;
        ai = true;
        ui = true;
        lsp = true;
        compilers = true;
        debuggers = true;
      };
    };

  minimal =
    { pkgs, ... }:
    {
      settings = {
        wrapRc = true;
        aliases = [
          "nvim"
          "rdvim"
          "vim"
        ];
      };

      categories = {
        core = true;
        editing = true;
        git = true;
      };
    };

  test =
    { pkgs, ... }:
    {
      settings = {
        wrapRc = false;
        aliases = [
          "nvim-test"
          "vim"
        ];
      };

      categories = {
        core = true;
        editing = true;
        extra = true;
        treesitter = true;
        git = true;
        snippets = true;
        ai = true;
        ui = true;
        lsp = true;
        compilers = true;
      };
    };
}

{ inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.helix = inputs.nix-wrapper-modules.wrappers.helix.wrap {
        inherit pkgs;

        settings = {
          theme = "catppuccin_mocha";
          editor = {
            line-number = "relative";
            cursorline = true;
            bufferline = "multiple";
            color-modes = true;
            gutters = [
              "diagnostics"
              "spacer"
              "diff"
              "spacer"
              "line-numbers"
            ];
          };
        };

        runtimePkgs = [
          pkgs.nixd
          pkgs.nixfmt
        ];

        languages = {
          language-server.nixd = {
            command = "nixd";
            config.nixd = {
              nixpkgs.expr = "import ${pkgs.path} { system = \"${pkgs.stdenv.hostPlatform.system}\"; }";
              formatting.command = [ "nixfmt" ];
            };
          };
          language = [
            {
              name = "nix";
              auto-format = true;
              language-servers = [ "nixd" ];
              formatter.command = "nixfmt";
            }
          ];
        };
      };
    };
}

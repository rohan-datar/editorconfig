{ lib, ... }:
{
  perSystem =
    {
      pkgs,
      config,
      ...
    }:
    {
      formatter = pkgs.treefmt.withConfig {
        runtimeInputs = with pkgs; [
          # keep-sorted start
          actionlint
          deadnix
          keep-sorted
          nixfmt
          shellcheck
          shfmt
          statix
          stylua
          # keep-sorted end

          (writeShellScriptBin "statix-fix" ''
            for file in "$@"; do
              ${lib.getExe statix} fix "$file"
            done
          '')
        ];

        settings = {
          on-unmatched = "info";
          tree-root-file = "flake.nix";

          excludes = [
            "secrets/*"
          ];

          formatter = {
            # keep-sorted start block=yes newline_separated=yes
            deadnix = {
              command = "deadnix";
              includes = [ "*.nix" ];
            };

            keep-sorted = {
              command = "keep-sorted";
              includes = [ "*" ];
            };

            nixfmt = {
              command = "nixfmt";
              includes = [ "*.nix" ];
            };

            shellcheck = {
              command = "shellcheck";
              includes = [
                "*.sh"
                "*.bash"
                "*.envrc"
                "*.envrc.*"
              ];
            };

            shfmt = {
              command = "shfmt";
              options = [
                "-s"
                "-w"
                "-i"
                "2"
              ];
              includes = [
                "*.sh"
                "*.bash"
                "*.envrc"
                "*.envrc.*"
              ];
            };

            statix = {
              command = "statix-fix";
              includes = [ "*.nix" ];
            };

            stylua = {
              command = "stylua";
              includes = [ "*.lua" ];
            };
            # keep-sorted end
          };
        };
      };
    };
}

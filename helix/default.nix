{ inputs, ... }:
{
  perSystem =
    { pkgs, self', ... }:
    let
      inherit (pkgs.lib) optionalAttrs optionals;
      inherit (pkgs.stdenv.hostPlatform) isDarwin;

      # Python env so pylsp can load its pylint plugin (mirrors Emacs'
      # flymake-collection pylint checker).
      pythonLsp = pkgs.python3.withPackages (ps: [
        ps.python-lsp-server
        ps.pylint
      ]);

      prettier = parser: {
        command = "prettier";
        args = [
          "--parser"
          parser
        ];
      };
      # Keep appearance and editing behavior identical across both profiles.
      mkHelix =
        full:
        inputs.nix-wrapper-modules.wrappers.helix.wrap {
          inherit pkgs;

          settings = {
            theme = "catppuccin_mocha_transparent";
            editor = {
              line-number = "relative";
              cursorline = true;
              bufferline = "multiple";
              color-modes = true;
              lsp.display-inlay-hints = true;
              popup-border = "all";
            };
          };

          themes.catppuccin_mocha_transparent = {
            inherits = "catppuccin_mocha";
            "ui.background" = {
              fg = "text";
            };
            # Floating windows
            "ui.popup" = {
              fg = "text";
            };
            "ui.help" = {
              fg = "overlay2";
            };
            "ui.menu" = {
              fg = "overlay2";
            };
            # Active buffer tab used the editor background color
            "ui.bufferline.active" = {
              fg = "mauve";
              underline = {
                color = "mauve";
                style = "line";
              };
            };
          };

          # Servers need only Nix tooling. The full profile keeps the rdmacs
          # toolset (emacs/packages.nix runtimeDeps), including TeX.
          runtimePkgs = [
            pkgs.nixd
            pkgs.nixfmt
          ]
          ++ optionals full [
            # Language servers
            pkgs.clang-tools # clangd, clang-format
            pkgs.lua-language-server
            pkgs.vscode-langservers-extracted # html, css, json
            pkgs.gopls
            pkgs.rust-analyzer
            pkgs.texlab

            # Linters, exposed via language servers since helix has no
            # standalone linter integration
            pkgs.golangci-lint
            pkgs.golangci-lint-langserver
            pkgs.shellcheck
            pkgs.bash-language-server
            pythonLsp

            # Formatters
            pkgs.stylua
            pkgs.rustfmt
            pkgs.prettier
            pkgs.shfmt

            # Debuggers
            pkgs.delve # go (dlv dap)
            pkgs.lldb # c/c++/rust (lldb-dap)

            # LaTeX toolchain (latexmk, chktex); same store path as rdmacs
            self'.packages.texliveCombined
          ]
          ++ optionals (full && isDarwin) [
            # Swift: sourcekit-lsp comes from the system Xcode toolchain
            pkgs.swiftformat
          ];

          # Languages not listed here (dotenv, pkl, kotlin, just, mermaid,
          # markdown) use helix's built-in grammars and defaults.
          languages = {
            language-server = {
              nixd = {
                command = "nixd";
                config.nixd = {
                  nixpkgs.expr = "import ${pkgs.path} { system = \"${pkgs.stdenv.hostPlatform.system}\"; }";
                  formatting.command = [ "nixfmt" ];
                };
              };
            }
            // optionalAttrs full {
              lua-language-server.config.Lua.hint.enable = true;

              pylsp.config.pylsp.plugins.pylint.enabled = true;

              texlab.config.texlab = {
                # Rebuild with latexmk on save (like rdmacs/latex-compile-on-save)
                build = {
                  onSave = true;
                  executable = "latexmk";
                  args = [
                    "-pdf"
                    "-interaction=nonstopmode"
                    "-synctex=1"
                    "%f"
                  ];
                };
                chktex.onOpenAndSave = true;
              };
            };

            language = [
              {
                name = "nix";
                auto-format = true;
                language-servers = [ "nixd" ];
                formatter.command = "nixfmt";
              }
            ]
            ++ optionals full [
              {
                name = "lua";
                auto-format = true;
                formatter = {
                  command = "stylua";
                  args = [ "-" ];
                };
              }
              {
                name = "rust";
                auto-format = true;
              }
              {
                name = "go";
                auto-format = true;
              }
              {
                name = "c";
                auto-format = true;
              }
              {
                name = "cpp";
                auto-format = true;
              }
              {
                name = "bash";
                auto-format = true;
                formatter = {
                  command = "shfmt";
                  args = [
                    "-i"
                    "2"
                    "-s"
                  ];
                };
              }
              {
                name = "python";
                language-servers = [ "pylsp" ];
              }
              {
                name = "html";
                auto-format = true;
                language-servers = [ "vscode-html-language-server" ];
                formatter = prettier "html";
              }
              {
                name = "css";
                auto-format = true;
                formatter = prettier "css";
              }
              {
                name = "scss";
                auto-format = true;
                formatter = prettier "scss";
              }
              {
                name = "json";
                auto-format = true;
                formatter = prettier "json";
              }
              {
                name = "javascript";
                auto-format = true;
                formatter = prettier "babel";
              }
              {
                name = "jsx";
                auto-format = true;
                formatter = prettier "babel";
              }
              {
                name = "typescript";
                auto-format = true;
                formatter = prettier "typescript";
              }
              {
                name = "tsx";
                auto-format = true;
                formatter = prettier "typescript";
              }
            ]
            ++ optionals (full && isDarwin) [
              {
                name = "swift";
                auto-format = true;
                formatter = {
                  command = "swiftformat";
                  args = [ "--quiet" ];
                };
              }
            ];
          };
        };
    in
    {
      packages = {
        helix-minimal = mkHelix false;
        helix-full = mkHelix true;
        # Preserve the existing workstation toolchain for current consumers.
        helix = self'.packages.helix-full;
      };

      # Only builds the minimal profile, never the workstation/TeX toolchain.
      checks.helix-minimal =
        pkgs.runCommand "helix-minimal-check"
          {
            nativeBuildInputs = [ self'.packages.helix-minimal ];
            exportReferencesGraph = [
              "minimal-closure"
              self'.packages.helix-minimal
            ];
          }
          ''
            if grep -E '/nix/store/[^ ]*-(texlive|texlab)' minimal-closure; then
              echo "Minimal Helix must not depend on TeX" >&2
              exit 1
            fi
            export HOME="$TMPDIR"
            hx --version
            hx --health nix > "$out"
            grep -F /bin/nixd "$out"
            grep -F /bin/nixfmt "$out"
          '';
    };
}

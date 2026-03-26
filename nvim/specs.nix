inputs:
{
  config,
  lib,
  pkgs,
  wlib,
  ...
}:
let
  vp = pkgs.vimPlugins;
  values = builtins.attrValues;
  inherit (builtins) mapAttrs;
  inherit (lib) mkDefault optionals;
  inherit (config.nvim-lib) mkPlugin;
in
{
  config.info.cats = mapAttrs (_: v: v.enable) config.specs;

  config.specs = {
    core = {
      enable = true;
      data = [
        {
          name = "startup";
          lazy = false;
          data = values {
            inherit (vp)
              lze
              lzextras
              catppuccin-nvim
              vim-sleuth
              vim-repeat
              vim-abolish
              fidget-nvim
              ;
          };
        }
        {
          name = "deferred";
          lazy = true;
          data = values {
            inherit (vp)
              mini-nvim
              snacks-nvim
              blink-cmp
              auto-hlsearch-nvim
              vim-tmux-navigator
              oil-nvim
              nvim-surround
              ;
          };
        }
      ];
    };
    compile = {
      enable = mkDefault true;
      data = mkPlugin "compile-nvim" inputs."plugins-compile-nvim";
    };
    editing = {
      enable = mkDefault true;
      data = [
        {
          name = "check";
          data = values {
            inherit (vp)
              nvim-lint
              conform-nvim
              ;
          };
        }
        {
          name = "treesitter";
          lazy = true;
          data = [
            {
              name = "nvim-treesitter";
              data = vp.nvim-treesitter.withAllGrammars;
            }
            {
              name = "nvim-treesitter-context";
              data = vp.nvim-treesitter-context;
            }
            {
              name = "nvim-treesitter-textobjects";
              data = vp.nvim-treesitter-textobjects;
            }
          ];
        }
      ];
    };
    snippets = {
      enable = mkDefault true;
      lazy = true;
      data = values {
        inherit (vp)
          luasnip
          friendly-snippets
          ;
      };
    };
    lsp = {
      enable = mkDefault true;
      data = [
        {
          name = "rustaceanvim";
          data = vp.rustaceanvim;
        }
        {
          name = "lsp-helpers";
          lazy = true;
          data = [
            {
              name = "nvim-lspconfig";
              data = vp.nvim-lspconfig;
            }
            {
              name = "inlay-hints";
              data = mkPlugin "inlay-hints" inputs."plugins-inlay-hints";
            }
          ];

        }
      ];
    };
    ui = {
      enable = mkDefault true;
      data = [
        {
          name = "tiny-inline-diagnostic-nvim";
          data = vp.tiny-inline-diagnostic-nvim;
        }
        {
          name = "ui-deferred";
          lazy = true;
          data = values {
            inherit (vp)
              todo-comments-nvim
              nvim-ufo
              statuscol-nvim
              promise-async
              render-markdown-nvim
              quicker-nvim
              golden-ratio
              eyeliner-nvim
              ;
          };
        }
      ];
    };
    ai = {
      enable = mkDefault true;
      lazy = true;
      data = values {
        inherit (vp)
          copilot-lua
          blink-copilot
          CopilotChat-nvim
          ;
      };
    };
    git = {
      enable = mkDefault true;
      lazy = true;
      data = values {
        inherit (vp)
          neogit
          gitsigns-nvim
          ;
      };
    };
    debuggers = {
      enable = mkDefault true;
      lazy = true;
      data = values {
        inherit (vp)
          nvim-dap
          debugmaster-nvim
          nvim-dap-go
          ;
      };
    };
    extras = {
      enable = mkDefault true;
      lazy = true;
      data = values {
        inherit (vp)
          lazydev-nvim
          obsidian-nvim
          go-nvim
          direnv-vim
          ;
      };
    };
  };

  config.extraPackages =
    (values {
      inherit (pkgs)
        universal-ctags
        ripgrep
        fd
        fzf
        jq
        yq
        tree-sitter
        ;
    })
    ++ optionals config.specs.compile.enable (values {
      inherit (pkgs)
        go
        cargo
        rustc
        zig
        clang
        nodejs
        ;
    })
    ++ optionals config.specs.debuggers.enable (values {
      inherit (pkgs)
        lldb
        # gdb
        delve
        ;
    })
    ++ optionals config.specs.lsp.enable (values {
      inherit (pkgs)
        nil
        rust-analyzer
        gopls
        lua-language-server
        zls
        jdt-language-server
        superhtml
        markdown-oxide
        clang-tools
        ;
      inherit (pkgs.nodePackages) vscode-json-languageserver;
    })
    ++ optionals config.specs.editing.enable (values {
      inherit (pkgs)
        codespell
        stylua
        gofumpt
        rustfmt
        yamllint
        nixfmt
        conform
        ;
    })
    ++ optionals config.specs.git.enable (values {
      inherit (pkgs)
        lazygit
        ;
    });

}

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
  inherit (lib)
    mkOption
    optionals
    types
    ;
  inherit (config.nvim-lib) mkPlugin;
  full = config.profile != "minimal";
in
{
  options.profile = mkOption {
    type = types.enum [
      "full"
      "minimal"
      "test"
    ];
    default = "full";
    description = "Build profile controlling which specs are enabled";
  };
  config.info.cats = mapAttrs (_: v: v.enable) config.specs;

  config.specs = {
    core = {
      enable = true;
      data = [
        vp.lze
        vp.lzextras
        vp.vim-sleuth
        vp.vim-repeat
        vp.vim-abolish
        {
          name = "catppuccin.nvim";
          data = vp.catppuccin-nvim;
        }
        {
          name = "fidget.nvim";
          data = vp.fidget-nvim;
        }
        {
          name = "mini.nvim";
          lazy = true;
          data = vp.mini-nvim;
        }
        {
          name = "snacks.nvim";
          lazy = true;
          data = vp.snacks-nvim;
        }
        {
          name = "blink.cmp";
          lazy = true;
          data = vp.blink-cmp;
        }
        {
          name = "auto-hlsearch.nvim";
          lazy = true;
          data = vp.auto-hlsearch-nvim;
        }
        {
          name = "vim-tmux-navigator";
          lazy = true;
          data = vp.vim-tmux-navigator;
        }
        {
          name = "oil.nvim";
          lazy = true;
          data = vp.oil-nvim;
        }
        {
          name = "nvim-surround";
          lazy = true;
          data = vp.nvim-surround;
        }
        {
          name = "tiny-code-action.nvim";
          lazy = true;
          data = mkPlugin "tiny-code-action.nvim" inputs."plugins-tiny-code-action-nvim";
        }
      ];
    };
    compile = {
      enable = full;
      data = mkPlugin "compile.nvim" inputs."plugins-compile-nvim";
    };
    editing = {
      enable = true;
      data = [
        vp.nvim-lint
        {
          name = "conform.nvim";
          data = vp.conform-nvim;
        }
        {
          name = "nvim-treesitter";
          lazy = true;
          data = vp.nvim-treesitter.withAllGrammars;
        }
        {
          name = "nvim-treesitter-context";
          lazy = true;
          data = vp.nvim-treesitter-context;
        }
        {
          name = "nvim-treesitter-textobjects";
          lazy = true;
          data = vp.nvim-treesitter-textobjects;
        }
      ];
    };
    snippets = {
      enable = true;
      lazy = true;
      data = values {
        inherit (vp)
          luasnip
          friendly-snippets
          ;
      };
    };
    lsp = {
      enable = full;
      data = [
        {
          name = "rustaceanvim";
          data = vp.rustaceanvim;
        }
        {
          name = "nvim-lspconfig";
          lazy = true;
          data = vp.nvim-lspconfig;
        }
        {
          name = "inlay-hints";
          lazy = true;
          data = mkPlugin "inlay-hints" inputs."plugins-inlay-hints";
        }
      ];
    };
    ui = {
      enable = full;
      data = [
        {
          name = "tiny-inline-diagnostic.nvim";
          data = vp.tiny-inline-diagnostic-nvim;
        }
        {
          name = "todo-comments.nvim";
          lazy = true;
          data = vp.todo-comments-nvim;
        }
        {
          name = "nvim-ufo";
          lazy = true;
          data = vp.nvim-ufo;
        }
        {
          name = "statuscol.nvim";
          lazy = true;
          data = vp.statuscol-nvim;
        }
        {
          name = "promise-async";
          lazy = true;
          data = vp.promise-async;
        }
        {
          name = "render-markdown.nvim";
          lazy = true;
          data = vp.render-markdown-nvim;
        }
        {
          name = "quicker.nvim";
          lazy = true;
          data = vp.quicker-nvim;
        }
        {
          name = "golden-ratio";
          lazy = true;
          data = vp.golden-ratio;
        }
        {
          name = "eyeliner.nvim";
          lazy = true;
          data = vp.eyeliner-nvim;
        }
      ];
    };
    ai = {
      enable = full;
      lazy = true;
      data = [
        vp.blink-copilot
        {
          name = "copilot.lua";
          data = vp.copilot-lua;
        }
        {
          name = "agentic.nvim";
          lazy = true;
          data = mkPlugin "agentic.nvim" inputs."plugins-agentic-nvim";
        }
      ];
    };
    git = {
      enable = true;
      lazy = true;
      data = [
        vp.neogit
        {
          name = "gitsigns.nvim";
          data = vp.gitsigns-nvim;
        }
      ];
    };
    debuggers = {
      enable = full;
      lazy = true;
      data = [
        vp.nvim-dap
        vp.nvim-dap-go
        {
          name = "debugmaster.nvim";
          data = vp.debugmaster-nvim;
        }
      ];
    };
    extras = {
      enable = full;
      lazy = true;
      data = [
        {
          name = "lazydev.nvim";
          data = vp.lazydev-nvim;
        }
        {
          name = "obsidian.nvim";
          data = vp.obsidian-nvim;
        }
        {
          name = "go.nvim";
          data = vp.go-nvim;
        }
        {
          name = "direnv.vim";
          data = vp.direnv-vim;
        }
      ];
    };
  };

  config.runtimePkgs =
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
        gdb
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
        vscode-json-languageserver
        ;
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
    })
    ++ optionals config.specs.ai.enable (values {
      inherit (pkgs)
        claude-agent-acp
        github-copilot-cli
        ;
    });

}

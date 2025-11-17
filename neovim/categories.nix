inputs:
{
  pkgs,
  settings,
  categories,
  extra,
  name,
  mkPlugin,
  ...
}@packageDef:
let
  vp = pkgs.vimPlugins;
  np = pkgs.neovimPlugins;
  values = builtins.attrValues;
in
{
  startupPlugins = {
    core = values {
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

    editing = values {
      inherit (vp)
        nvim-lint
        conform-nvim
        ;
    };
    lsp = values {
      inherit (vp)
        nvim-lspconfig
        ;
      inherit (np) inlay-hints;
    };

  };
  optionalPlugins = {
    core = values {
      inherit (vp)
        mini-nvim
        snacks-nvim
        blink-cmp
        auto-hlsearch-nvim
        vim-tmux-navigator
        oil-nvim
        ;
    };

    treesitter = [
      (vp.nvim-treesitter.withPlugins (plugins: vp.nvim-treesitter.allGrammars))
    ]
    ++ values {
      inherit (vp)
        nvim-treesitter-context
        nvim-treesitter-textobjects
        nvim-treesitter-textsubjects
        ;
    };

    ui = values {
      inherit (vp)
        todo-comments-nvim
        nvim-ufo
        statuscol-nvim
        promise-async
        render-markdown-nvim
        quicker-nvim
        tiny-inline-diagnostic-nvim
        ;
    };

    ai = values {
      inherit (vp)
        copilot-lua
        blink-copilot
        codecompanion-nvim
        ;
    };

    git = values {
      inherit (vp)
        neogit
        gitsigns-nvim
        ;
    };

    snippets = values {
      inherit (vp)
        luasnip
        friendly-snippets
        ;
    };

    extra = values {
      inherit (vp)
        lazydev-nvim
        obsidian-nvim
        go-nvim
        ;
    };

    debuggers = values { inherit (vp) nvim-dap; };
  };

  lspsAndRuntimeDeps = {
    core = values {
      inherit (pkgs)
        universal-ctags
        ripgrep
        fd
        fzf
        jq
        yq
        ;
    };

    compilers = values {
      inherit (pkgs)
        go
        cargo
        rustc
        zig
        clang

        ;
    };

    debuggers = values {
      inherit (pkgs)
        delve
        ;
    };

    lsp = values {
      inherit (pkgs)
        nil
        rust-analyzer
        gopls
        lua-language-server
        zls
        jdt-language-server
        superhtml
        markdown-oxide
        ;
      inherit (pkgs.nodePackages) vscode-json-languageserver;
    };

    editing = values {
      inherit (pkgs)
        codespell
        stylua
        gofumpt
        yamllint
        nixfmt
        conform
        ;
    };

    git = values {
      inherit (pkgs)
        lazygit
        ;
    };
  };
}

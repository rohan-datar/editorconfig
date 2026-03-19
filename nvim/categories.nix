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

    compilers = values {
      inherit (np) compile-nvim;
    };

    lsp = values {
      inherit (vp) rustaceanvim;
    };

    ui = values {
      inherit (vp) tiny-inline-diagnostic-nvim;
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
        nvim-surround
        ;
    };

    treesitter = [
      vp.nvim-treesitter.withAllGrammars
    ]
    ++ values {
      inherit (vp)
        nvim-treesitter-context
        nvim-treesitter-textobjects
        ;
    };

    lsp = values {
      inherit (vp)
        nvim-lspconfig
        ;
      inherit (np) inlay-hints;
    };

    ui = values {
      inherit (vp)
        todo-comments-nvim
        nvim-ufo
        statuscol-nvim
        promise-async
        render-markdown-nvim
        quicker-nvim
        ;
    };

    ai = values {
      inherit (vp)
        copilot-lua
        blink-copilot
        CopilotChat-nvim
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
        direnv-vim
        golden-ratio
        ;
    };

    debuggers = values {
      inherit (vp)
        nvim-dap
        debugmaster-nvim
        nvim-dap-go
        ;
    };
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
        tree-sitter
        ;
    };

    compilers = values {
      inherit (pkgs)
        go
        cargo
        rustc
        zig
        clang
        nodejs
        ;
    };

    debuggers = values {
      inherit (pkgs)
        lldb
        # gdb
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
        clang-tools
        ;
      inherit (pkgs.nodePackages) vscode-json-languageserver;
    };

    editing = values {
      inherit (pkgs)
        codespell
        stylua
        gofumpt
        rustfmt
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

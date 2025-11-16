inputs:
let
  inherit (inputs.nixCats) utils;
in
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
  values = builtins.attrValues;
in
{
  startupPlugins = {
    core = values {
      inherit (vp)
        lze
        lzextras
        plenary-nvim
        mini-nvim
        snacks-nvim
        blink-cmp
        catppuccin-nvim
        ;
    };

    editing = values {
      inherit (vp)
        nvim-lint
        conform-nvim
        ;
    };

    extra = values {
      inherit (vp)
        fidget-nvim
        nvim-lspconfig
        ;
    };
  };
  optionalPlugins = {
    core = values {
      inherit (vp)
        vim-sleuth
        oil-nvim
        vim-repeat
        vim-abolish
        vim-tmux-navigator
        ;
    };

    treesitter = (vp.nvim-treesitter.withPlugins (plugins: vp.nvim-treesitter.allGrammars));

    ui = values {
      inherit (vp)
        nvim-treesitter-context
        nvim-treesitter-textobjects
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
        ;
    };

    debuggers = values { inherit (vp) nvim-dap; };
  };

  lspAndRuntimeDeps = {
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
        ;
      inherit (pkgs.nodePackages) vscode-json-languageserver;
    };

    lint = values {
      inherit (pkgs)
        codespell
        stylua
        gofumpt
        yamllint
        superhtml
        nixfmt
        ;
    };
  };
}

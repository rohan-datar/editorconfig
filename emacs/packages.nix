# Emacs packages and runtime dependencies for rdmacs
{ pkgs }:
let
  values = builtins.attrValues;
in
{
  # External tools (LSPs, formatters, etc.) to be available in PATH
  runtimeDeps = values {
    inherit (pkgs)
      # general environment
      ripgrep
      fd
      nix # needed for pcomplete/nix and general nix commands

      # Language servers
      clang-tools # clangd
      nil # Nix LSP
      lua-language-server
      superhtml
      gopls
      rust-analyzer

      # Formatters
      stylua
      rustfmt
      prettier
      swiftformat
      nixfmt
      shfmt

      # Linters (for flymake-collection)
      shellcheck
      golangci-lint
      pylint
      yamllint
      codespell

      # Debuggers (for dap-mode)
      delve # Go debugger (dlv)
      gdb
      # GDB for C/C++
      lldb

      claude-code
      ;
  };

  # Emacs packages function for withPackages
  emacsPackages =
    epkgs:
    values {
      inherit (epkgs)
        # Evil mode
        evil
        evil-collection
        evil-surround
        evil-matchit
        evil-multiedit
        evil-mc
        evil-nerd-commenter

        # Keybindings
        general

        # Appearance
        catppuccin-theme
        doom-modeline
        nerd-icons
        nerd-icons-dired
        nerd-icons-ibuffer
        highlight-indent-guides

        # Development
        projectile
        sideline
        sideline-flymake
        flymake-collection
        yasnippet
        yasnippet-snippets
        eldoc-box
        format-all
        treesit-fold
        treesit-auto

        # LSP
        lsp-mode
        lsp-ui

        # Debugger
        dap-mode

        # Language modes
        nix-mode
        lua-mode
        rust-mode
        dotenv-mode
        web-mode
        nix-ts-mode
        markdown-mode
        add-node-modules-path

        # Terminal
        eat
        vterm

        # Version Control
        transient
        magit
        diff-hl
        blamer

        # Completion
        corfu
        nerd-icons-corfu
        cape
        orderless
        vertico
        marginalia
        nerd-icons-completion

        # Org mode
        toc-org
        org-superstar
        visual-fill-column

        #AI
        copilot-chat
        claude-code

        # Other packages
        consult
        helpful
        diminish
        rainbow-delimiters
        neotree
        vundo
        undo-fu-session
        direnv
        ws-butler
        ;

      # Tree-sitter grammars (for Emacs 29+ built-in tree-sitter)
      # Exclude broken grammars (tree-sitter-razor)
      treesit = epkgs.treesit-grammars.with-grammars (
        grammars: builtins.filter (g: g.pname or "" != "tree-sitter-razor") (builtins.attrValues grammars)
      );
    };
}

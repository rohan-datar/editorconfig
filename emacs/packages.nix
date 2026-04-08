# Emacs packages and runtime dependencies for rdmacs
{ pkgs }:
let
  ecpkgs = pkgs.customEmacsPackages;
  values = builtins.attrValues;
  inherit (pkgs.stdenv) isDarwin;
  inherit (pkgs.lib) optionalAttrs;
in
{
  # External tools (LSPs, formatters, etc.) to be available in PATH
  runtimeDeps = values (
    {
      inherit (pkgs)
        # general environment
        ripgrep
        fd
        # needed for pcomplete/nix and general nix commands
        nix
        direnv

        # Language servers
        clang-tools # clangd
        nil # Nix LSP
        lua-language-server
        vscode-langservers-extracted
        gopls
        rust-analyzer

        # Formatters
        stylua
        rustfmt
        prettier
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
        lldb

        claude-code
        claude-agent-acp
        ;
    }
    // pkgs.lib.optionalAttrs isDarwin {
      # Swift development tools (Darwin only)
      # Note: System Swift toolchain is preferred for iOS/tvOS development
      # These are used when available but emacs will fall back to system tools
      inherit (pkgs)
        # Swift formatters
        swiftformat
        # Swift linter (swiftlint not available in nixpkgs, use system version)
        ;
    }
  );

  # Emacs packages function for withPackages
  emacsPackages =
    epkgs:
    values (
      {
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
          page-break-lines
          dashboard
          golden-ratio

          # Development
          projectile
          consult-dir
          sideline
          flyover
          flymake-collection

          yasnippet
          yasnippet-snippets
          eldoc-box
          format-all
          treesit-fold
          treesit-auto
          fancy-compilation

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
          agent-shell
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
          rainbow-mode
          hl-todo
          ws-butler
          wgrep
          embark
          embark-consult
          ;

        # Custom packages from overlay
        # inherit (ecpkgs)
        #   ghostel
        #   ;

        # Tree-sitter grammars (for Emacs 29+ built-in tree-sitter)
        # Exclude broken grammars (tree-sitter-razor)
        treesit = epkgs.treesit-grammars.with-grammars (
          grammars: builtins.filter (g: g.pname or "" != "tree-sitter-razor") (builtins.attrValues grammars)
        );
      }
      // optionalAttrs isDarwin {
        # Swift development (Darwin only)
        inherit (epkgs)
          swift-mode
          swift-ts-mode
          request # Dependency for swift-development
          ;
        # Custom packages from overlay
        inherit (ecpkgs)
          swift-development # Xcode-like Swift development
          ;
      }
    );
}

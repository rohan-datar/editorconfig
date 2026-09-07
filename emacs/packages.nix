# Emacs packages and runtime dependencies for rdmacs
{ pkgs, inputs, ... }:
let
  ecpkgs = pkgs.customEmacsPackages;
  values = builtins.attrValues;
  inherit (pkgs.stdenv) isDarwin;
  inherit (pkgs.lib) optionalAttrs;
  # Full TeX Live distribution for AUCTeX, with GUI apps filtered out.
  texliveCombined = pkgs.texlive.combine {
    inherit (pkgs.texlive) scheme-full;
    pkgFilter =
      p:
      (p.tlType == "run" || p.tlType == "bin" || p.pname == "core" || p.hasManpages or false)
      && !builtins.elem (p.pname or p.name) [
        "asymptote" # xasy GUI; also breaks the build via pyqt5 on darwin
        "tlshell" # tcl/tk GUI
        "texdoctk" # perl/tk GUI
        "xdvi" # X11 dvi viewer
      ];
  };
in
{
  inherit texliveCombined;
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
        texlab

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

        # preview-latex: pdf2dsc for the PDF2DSC preview pipeline
        ghostscript

        # miscellaneous
        mermaid-cli
        ;

      # Full TeX Live distribution for AUCTeX, with GUI apps filtered out.
      # Same derivation as the texliveCombined flake output, so the system
      # PATH copy and this wrapper copy share one store path.
      texlive = texliveCombined;
    }
    // pkgs.lib.optionalAttrs isDarwin {
      # Swift development tools (Darwin only)
      # Note: System Swift toolchain is preferred for iOS/tvOS development
      # These are used when available but emacs will fall back to system tools
      inherit (pkgs)
        # Swift formatters
        swiftformat
        swiftlint
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
          ligature
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
          add-node-modules-path
          nix-ts-mode
          markdown-mode
          pkl-mode
          kotlin-mode
          applescript-mode
          mermaid-mode
          just-mode
          justl

          # LaTeX
          auctex
          pdf-tools

          # Terminal
          eat
          ghostel

          # Version Control
          transient
          magit
          git-timemachine
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
          prescient
          corfu-prescient
          vertico-prescient

          # Org mode
          toc-org
          org-superstar
          visual-fill-column
          ob-mermaid

          # Other packages
          consult
          helpful
          diminish
          rainbow-delimiters
          treemacs
          treemacs-evil
          project-treemacs
          treemacs-nerd-icons
          treemacs-magit
          treemacs-tab-bar
          vundo
          undo-fu-session
          envrc
          rainbow-mode
          hl-todo
          ws-butler
          wgrep
          embark
          embark-consult

          agent-shell
          ;

        # Custom packages from overlay
        inherit (ecpkgs)
          evil-ghostel
          ;

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

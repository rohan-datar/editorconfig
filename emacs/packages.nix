# Emacs packages and runtime dependencies for rdmacs
{ pkgs }:
let
  # Override ws-butler to fetch from GitHub instead of savannah.gnu.org
  # Workaround for https://github.com/nix-community/emacs-overlay/issues/499
  ws-butler-github = pkgs.emacs-pgtk.pkgs.trivialBuild {
    pname = "ws-butler";
    version = "20250613";
    src = pkgs.fetchFromGitHub {
      owner = "lewang";
      repo = "ws-butler";
      rev = "67c49cfdf5a5a9f28792c500c8eb0017cfe74a3a";
      hash = "sha256-maOhnDkG3GibrbI1EuPRY+Ej4AZJgbFheu6lC72vZ4w=";
    };
  };
in
{
  # External tools (LSPs, formatters, etc.) to be available in PATH
  runtimeDeps = with pkgs; [
	# general environment
	ripgrep
	fd
    # Language servers
    clang-tools # clangd
    nil # Nix LSP
	claude-code
  ];

  # Emacs packages function for withPackages
  emacsPackages =
    epkgs: with epkgs; [
      # Evil mode
      evil
      evil-collection
      evil-surround
      evil-matchit
	  evil-multiedit
	  evil-mc

      # Keybindings
      general

      # Appearance
      catppuccin-theme
      doom-modeline
      nerd-icons
      nerd-icons-dired
      nerd-icons-ibuffer
      indent-guide

      # Development
      projectile
      sideline
      sideline-flymake
      yasnippet
      yasnippet-snippets
      eldoc-box

      # LSP
      lsp-mode
      lsp-ui

      # Language modes
      nix-mode
      lua-mode
      rust-mode
      dotenv-mode
      web-mode
      nix-ts-mode

      # Tree-sitter grammars (for Emacs 29+ built-in tree-sitter)
      # Exclude broken grammars (tree-sitter-razor)
      (treesit-grammars.with-grammars (
        grammars: builtins.filter (g: g.pname or "" != "tree-sitter-razor") (builtins.attrValues grammars)
      ))

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

	  #AI
	  copilot-chat
	  claude-code

      # Other packages
      consult
      helpful
      diminish
      rainbow-delimiters
      ws-butler-github
      neotree
    ];
}

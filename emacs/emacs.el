;; The default is 800 kilobytes. Measured in bytes.
(setq gc-cons-threshold (* 50 1000 1000))

(let ((cache-dir (expand-file-name "~/.cache/emacs/")))
  ;; Ensure cache directory exists
  (unless (file-exists-p cache-dir)
    (make-directory cache-dir t))
  ;; Native compilation cache
  (when (boundp 'native-comp-eln-load-path)
    (startup-redirect-eln-cache (expand-file-name "eln-cache/" cache-dir)))
  ;; Yasnippet snippets directory
  (setq yas-snippet-dirs (list (expand-file-name "snippets/" cache-dir))))

(defun rdmacs/org-babel-tangle-config ()
  "Automatically tangle our init.org config file and refresh package-quickstart when we save it. Credit to Emacs From Scratch for this one!"
  (interactive)
  (when (string-equal (file-name-directory (buffer-file-name))
					  (expand-file-name user-emacs-directory))
    ;; Dynamic scoping to the rescue
    (let ((org-confirm-babel-evaluate nil))
	  (org-babel-tangle)
	  (package-quickstart-refresh)
	  )
    ))

(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'rdmacs/org-babel-tangle-config)))

(defun rdmacs/display-startup-time ()
  (message "Emacs loaded in %s with %d garbage collections."
           (format "%.2f seconds"
                   (float-time
					(time-subtract after-init-time before-init-time)))
           gcs-done))

(add-hook 'emacs-startup-hook #'rdmacs/display-startup-time)

(setq package-archives '(("melpa" . "https://melpa.org/packages/") ;; Sets default package repositories
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/"))) ;; For Eat Terminal

(setq package-quickstart t) ;; For blazingly fast startup times, this line makes startup miles faster

(use-package emacs
      :custom
      (auto-save-default nil)     ;; Stop creating # auto save files
      (column-number-mode t)      ;; Display the column number in the mode line.
      (create-lockfiles nil)      ;; Prevent the creation of lock files when editing.
      (menu-bar-mode nil)         ;; Disable the menu bar
      (scroll-bar-mode nil)       ;; Disable the scroll bar
      (tool-bar-mode nil)         ;; Disable the tool bar
      (inhibit-startup-screen t)  ;; Disable welcome screen

      (delete-by-moving-to-trash t) ;; Move deleted files to the trash instead of permanently deleting them.
      (delete-selection-mode 1)     ;; Enable replacing selected text with typed text.

      (electric-indent-mode nil)  ;; Turn off the weird indenting that Emacs does by default.
      (electric-pair-mode t)      ;; Turns on automatic parens pairing

      (blink-cursor-mode nil)     ;; Don't blink cursor
      (global-auto-revert-mode t) ;; Automatically reload file and show changes if the file has changed

      (recentf-mode t) ;; Enable recent file mode

      (global-visual-line-mode t)           ;; Enable truncated lines
      (display-line-numbers-type 'relative) ;; Relative line numbers
      (global-display-line-numbers-mode t)  ;; Display line numbers
      (global-hl-line-mode t)               ;; Highlights the current line

      (mouse-wheel-progressive-speed nil) ;; Disable progressive speed when scrolling
      (scroll-conservatively 10) ;; Smooth scrolling
      (scroll-margin 8)

      (tab-always-indent 'complete) ;; Make the TAB key complete text instead of just indenting.
      (tab-width 4)                 ;; Set the tab width to 4 spaces.
      (treesit-font-lock-level 4)   ;; Use advanced font locking for Treesit mode.

      (make-backup-files nil) ;; Stop creating ~ backup files
      (use-short-answers t)   ;; Use short answers in prompts for quicker responses (y instead of yes)

      (warning-minimum-level :emergency) ;; Set the minimum level of warnings to display.

      :hook
      (prog-mode . (lambda () (hs-minor-mode t))) ;; Enable folding hide/show globally
      :config
      ;; Move customization variables to a separate file and load it, avoid filling up init.el with unnecessary variables
      (setq custom-file (locate-user-emacs-file "custom-vars.el"))
      (load custom-file 'noerror 'nomessage)
      ;; Makes Emacs vertical divisor the symbol │ instead of |.
      ;; (set-display-table-slot standard-display-table 'vertical-border (make-glyph-code ?│))

      :bind (
             ([escape] . keyboard-escape-quit) ;; Makes Escape quit prompts (Minibuffer Escape)
             ;; Zooming In/Out
             ("C-+" . text-scale-increase)
             ("C--" . text-scale-decrease)
             ("<C-wheel-up>" . text-scale-increase)
             ("<C-wheel-down>" . text-scale-decrease))
)

(use-package dired
  :ensure nil                                                ;; This is built-in, no need to fetch it.
  :custom
  (dired-listing-switches "-lah --group-directories-first")  ;; Display files in a human-readable format and group directories first.
  (dired-dwim-target t)                                      ;; Enable "do what I mean" for target directories.
  (dired-guess-shell-alist-user
   '(("\\.\\(mp[34]\\|m4a\\|ogg\\|flac\\|webm\\|mkv\\)" "mpv" "xdg-open" "open") ;; Open audio and video files with `mpv'.
     (".*" "open" "xdg-open")))                              ;; Default opening command for other files.
  (dired-kill-when-opening-new-dired-buffer t)               ;; Close the previous buffer when opening a new `dired' instance.
  :config
  (when (eq system-type 'darwin)
    (setq insert-directory-program "/run/current-system/sw/bin/ls")))

(use-package evil
    :init
    (evil-mode)
    :config
    (evil-set-initial-state 'eat-mode 'insert) ;; Set initial state in eat terminal to insert mode
    (evil-set-initial-state 'vterm-mode 'insert) ;; Set initial state in vterm terminal to insert mode
	;; normalize some emacs and vim keybindings
    (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
    (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)
	;; fix jumplist
    (evil-define-key 'normal 'global (kbd "C-i") 'evil-jump-forward)
	;; diagnostic keybindings
    (evil-define-key 'normal 'global (kbd "] d") 'flymake-goto-next-error) ;; Go to next Flymake error
    (evil-define-key 'normal 'global (kbd "[ d") 'flymake-goto-prev-error) ;; Go to previous Flymake error

    (evil-define-key 'normal 'global (kbd "K") 'eldoc-box-help-at-point)

    ;; Diff-HL navigation for version control
    (evil-define-key 'normal 'global (kbd "] c") 'diff-hl-next-hunk) ;; Next diff hunk
    (evil-define-key 'normal 'global (kbd "[ c") 'diff-hl-previous-hunk) ;; Previous diff hunk
    :custom
    (evil-want-keybinding nil)    ;; Disable evil bindings in other modes (It's not consistent and not good)
    (evil-want-C-u-scroll t)      ;; Set C-u to scroll up
    (evil-want-C-i-jump nil)      ;; Disables C-i jump
    (evil-undo-system 'undo-redo) ;; C-r to redo
    (evil-want-fine-undo t)
    ;; Unmap keys in 'evil-maps. If not done, org-return-follows-link will not work
    :bind (:map evil-motion-state-map
                ("SPC" . nil)
                ("RET" . nil)
                ("TAB" . nil)))

(use-package evil-collection
    :after evil
    :config
	;; setting where to use evil-collection
	(setq evil-collection-mode-list '(dired ibuffer magit corfu vertico consult info neotree))
    (setq evil-collection-want-find-usages-bindings t)
    (evil-collection-init))

(use-package evil-surround
    :ensure t
    :after evil-collection
    :config
    (global-evil-surround-mode 1))

(use-package evil-matchit
    :ensure t
    :after evil-collection
    :config
    (global-evil-matchit-mode 1))

(use-package evil-multiedit
    :ensure t
    :after evil-collection
    :config
    (evil-multiedit-default-keybinds))

(use-package evil-mc
  :ensure t
  :after evil-multiedit
  :config
  (global-evil-mc-mode 1))

(use-package evil-nerd-commenter
  :config
  (evil-define-key 'normal 'global (kbd "gcc")  'evilnc-comment-or-uncomment-lines)
  (evil-define-key 'visual 'global (kbd "gc") 'evilnc-comment-or-uncomment-lines))

(use-package general
  :config
  (general-evil-setup) 
  ;; Set up 'C-SPC' as the leader key
  (general-create-definer rdmacs/leader-keys
    :states '(normal insert visual motion emacs) 
    :keymaps 'override
    :prefix "SPC"
    :global-prefix "C-SPC") ;; Set global leader key so we can access our keybindings from any state

  (rdmacs/leader-keys
    "." '(find-file :wk "Find file")
    "TAB" '(comment-line :wk "Comment lines")
    "q" '(flymake-show-buffer-diagnostics :wk "Flymake buffer diagnostic")
    "t t" '(vterm :wk "vterm terminal")
    "p" '(projectile-command-map :wk "Projectile")
    "s p" '(projectile-discover-projects-in-search-path :wk "Search for projects"))

  (rdmacs/leader-keys
    "s" '(:ignore t :wk "Search")
    "s c" '((lambda () (interactive) (find-file "~/editorconfig/emacs/emacs.org")) :wk "Find emacs Config")
    "s r" '(consult-recent-file :wk "Search recent files")
    "s f" '(consult-fd :wk "Search files with fd")
    "s g" '(consult-ripgrep :wk "Search with ripgrep")
    "s l" '(consult-line :wk "Search line")
	"s h" '(consult-info :wk "Search help")
    "s i" '(consult-imenu :wk "Search Imenu buffer locations")) ;; This one is really cool

  (rdmacs/leader-keys
    "f" '(:ignore t :wk "Files")
    "f f" '(dired :wk "Open dired")
    "f e" '(dired-jump :wk "Dired jump to current")
    "f s" '(neotree-toggle :wk "Toggle neotree"))
  
  (rdmacs/leader-keys
  "b" '(:ignore t :wk "Buffers")
  "b i" '(consult-buffer :wk "Switch buffer")
  "b b" '(ibuffer :wk "Ibuffer")
  "b d" '(kill-current-buffer :wk "Kill current buffer")
  "b k" '(kill-current-buffer :wk "Kill current buffer")
  "b x" '(kill-current-buffer :wk "Kill current buffer")
  "b n" '(next-buffer :wk "Next buffer")
  "b p" '(previous-buffer :wk "Previous buffer")
  "b r" '(revert-buffer :wk "Reload buffer"))

  (rdmacs/leader-keys
    "e" '(:ignore t :wk "Languages/LSP")
    "e e" '(lsp-restart-workspace :wk "LSP Restart")
    "e d" '(eldoc-doc-buffer :wk "Eldoc Buffer")
    "e f" '(lsp-format-buffer :wk "LSP Format")
    "e l" '(consult-flymake :wk "Consult Flymake")
    "e r" '(lsp-rename :wk "LSP Rename")
    "e i" '(lsp-find-definition :wk "Find definition")
    "e R" '(lsp-find-references :wk "Find references")
    "e a" '(lsp-execute-code-action :wk "Code action")
    "e h" '(lsp-ui-doc-glance :wk "Hover doc")
    "e v" '(:ignore t :wk "Elisp")
    "e v b" '(eval-buffer :wk "Evaluate elisp in buffer")
    "e v r" '(eval-region :wk "Evaluate elisp in region"))

  (rdmacs/leader-keys
    "g" '(:ignore t :wk "Git")
    "g g" '(magit-status :wk "Magit status")
    "g l" '(magit-log-current :wk "Show current log")
    "g d" '(magit-diff-buffer-file :wk "Show diff for the current file")
    "g D" '(diff-hl-show-hunk :wk "Show diff for hunk")
    "g b" '(magit-blame :wk "Git blame"))

  (rdmacs/leader-keys
    "d" '(:ignore t :wk "Debug")
    "d d" '(dap-debug :wk "Start debugging")
    "d t" '(dap-ui-sessions :wk "Toggle DAP UI")
    "d c" '(dap-continue :wk "Continue")
    "d b" '(dap-breakpoint-toggle :wk "Toggle breakpoint")
    "d B" '(dap-breakpoint-condition :wk "Conditional breakpoint")
    "d p" '(dap-pause :wk "Pause")
    "d s" '(dap-stop-thread :wk "Stop")
    "d q" '(dap-disconnect :wk "Quit/Disconnect")
    "d e" '(dap-eval :wk "Evaluate expression")
    "d E" '(dap-eval-region :wk "Evaluate region")
    "d i" '(dap-step-in :wk "Step into")
    "d o" '(dap-step-out :wk "Step out")
    "d n" '(dap-next :wk "Step over/next")
    "d r" '(dap-restart-frame :wk "Restart")
    "d R" '(dap-ui-repl :wk "Open REPL")
    "d l" '(dap-ui-locals :wk "Show locals")
    "d w" '(dap-ui-expressions-add :wk "Add watch expression"))

  (rdmacs/leader-keys
    "h" '(:ignore t :wk "Help") ;; To get more help use C-h commands (describe variable, function, etc.)
    "h q" '(save-buffers-kill-emacs :wk "Quit Emacs and Daemon")
	"h m" '(describe-mode :wk "Describe mode")
	"h k" '(helpful-key :wk "Describe keybinding")
	"h f" '(helpful-function :wk "Describe function")
	"h v" '(helpful-variable :wk "Describe variable"))

  (rdmacs/leader-keys
    "t" '(:ignore t :wk "Toggle")
    "t v" '(visual-line-mode :wk "Toggle truncated lines (wrap)")
    "t l" '(display-line-numbers-mode :wk "Toggle line numbers"))

 (defun rdmacs/smart-compile ()
   "Run `projectile-compile-project' if in a project, otherwise `compile'."
   (interactive)
   (if (projectile-project-p)
       (call-interactively #'projectile-compile-project)
     (call-interactively #'compile)))

 (rdmacs/leader-keys
  "c" '(:ignore t :wk "Compile & AI")
  "c c" '(rdmacs/smart-compile :wk "Run compile command")
  "c r" '(recompile :wk "Recompile")
  "c h" '(copilot-chat :wk "Open copilot chat")
  "c l" '(claude-code-transient :wk "Open claude code")))


;; Fix general.el leader key not working instantly in messages buffer with evil mode
(use-package emacs
  :ghook ('after-init-hook
           (lambda (&rest _)
             (when-let ((messages-buffer (get-buffer "*Messages*")))
               (with-current-buffer messages-buffer
                 (evil-normalize-keymaps))))
           nil nil t))

(use-package which-key
  :ensure nil ;; Don't install which-key because it's now built-in
  :init
  (which-key-mode 1)
  :diminish
  :custom
  (which-key-side-window-location 'bottom)
  (which-key-sort-order #'which-key-key-order-alpha) ;; Same as default, except single characters are sorted alphabetically
  (which-key-sort-uppercase-first nil)
  (which-key-add-column-padding 1) ;; Number of spaces to add to the left of each column
  (which-key-min-display-lines 6)  ;; Increase the minimum lines to display because the default is only 1
  (which-key-idle-delay 0.8)       ;; Set the time delay (in seconds) for the which-key popup to appear
  (which-key-max-description-length 25)
  (which-key-allow-imprecise-window-fit nil)) ;; Fixes which-key window slipping out in Emacs Daemon

(use-package catppuccin-theme
  :config
  (load-theme 'catppuccin t)) ;; We need to add t to trust this package

(if (eq system-type 'darwin)
    ;; macOS-specific transparency
    (progn
      (add-to-list 'default-frame-alist '(alpha . (90 . 90)))
      (set-frame-parameter nil 'alpha '(90 . 90)))
  (add-to-list 'default-frame-alist '(alpha-background . 90))) ;; For all new frames henceforth

(dolist (mode '(org-mode-hook
                eat-mode-hook
                shell-mode-hook
                neotree-mode-hook
                vterm-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(set-face-attribute 'default nil
                    :font "Maple Mono NF"
                    :height 140
                    :weight 'medium)
(set-face-attribute 'fixed-pitch nil
                    :font "Maple Mono NF"
                    :height 140
                    :weight 'medium)
(set-face-attribute 'variable-pitch nil
                    :font "SFProDisplay Nerd Font"
                    :height 140
                    :weight 'medium)
;; This sets the default font on all graphical frames created after restarting Emacs.
;; Does the same thing as 'set-face-attribute default' above, but emacsclient fonts
;; are not right unless I also add this method of setting the default font.
(add-to-list 'default-frame-alist '(font . "Maple Mono NF")) ;; Set your favorite font
(setq-default line-spacing 0.12)

(use-package doom-modeline
  :custom
  (doom-modeline-height 25) ;; Set modeline height
  :hook (after-init . doom-modeline-mode))

(use-package nerd-icons
  :if (display-graphic-p))

(use-package nerd-icons-dired
  :hook (dired-mode . (lambda () (nerd-icons-dired-mode t))))

(use-package nerd-icons-ibuffer
  :hook (ibuffer-mode . nerd-icons-ibuffer-mode))

(use-package indent-guide
  :defer t
  :ensure t
  :hook
  (prog-mode . indent-guide-mode)  ;; Activate indent-guide in programming modes.
  :config
  (setq indent-guide-char "│"))    ;; Set the character used for the indent guide.

(use-package projectile
  :config
  (projectile-mode)
  :custom
  ;; (projectile-auto-discover nil) ;; Disable auto search for better startup times ;; Search with a keybind
  (projectile-run-use-comint-mode t) ;; Interactive run dialog when running projects inside emacs (like giving input)
  (projectile-switch-project-action #'projectile-dired) ;; Open dired when switching to a project
  (projectile-project-search-path '("~/Documents/" "~/Documents/UW-Classes/" "~/Documents/dev/" ("~/" . 1)))) ;; . 1 means only search the first subdirectory level for projects

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook (((c-mode c++-mode
           lua-mode
           nix-mode nix-ts-mode
           go-mode go-ts-mode
           html-mode mhtml-mode web-mode)
          . lsp-deferred)
         (lsp-completion-mode . rdmacs/lsp-mode-setup-completion))
  :custom
  (lsp-keymap-prefix "C-c l")           ;; Set prefix for lsp-command-keymap
  (lsp-idle-delay 0.500)                ;; Debounce timer for server communication
  (lsp-log-io nil)                      ;; Disable logging for better performance
  (lsp-completion-provider :none)       ;; Use corfu instead of lsp's completion
  (lsp-headerline-breadcrumb-enable t)  ;; Show breadcrumb navigation
  (lsp-enable-symbol-highlighting t)    ;; Highlight references
  (lsp-enable-snippet t)                ;; Enable snippet support (yasnippet)
  (lsp-modeline-diagnostics-enable t)   ;; Show diagnostics in modeline
  :init
  (defun rdmacs/lsp-mode-setup-completion ()
    (setf (alist-get 'styles (alist-get 'lsp-capf completion-category-defaults))
          '(orderless)))
  :config
  ;; Register LSP clients with PATH lookup (Nix provides the servers)
  ;; nil - Nix
  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection "nil")
    :major-modes '(nix-mode nix-ts-mode)
    :server-id 'nil-ls))
  ;; lua-language-server - Lua
  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection "lua-language-server")
    :major-modes '(lua-mode)
    :server-id 'lua-ls))
  ;; clangd - C/C++
  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection "clangd")
    :major-modes '(c-mode c++-mode)
    :server-id 'clangd))
  ;; gopls - Go
  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection "gopls")
    :major-modes '(go-mode go-ts-mode)
    :server-id 'gopls))
  ;; rust-analyzer - rust
  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection "rust-analyzer")
    :major-modes '(rust-mode rust-ts-mode)
    :server-id 'rust-analyzer))
  ;; superhtml - HTML
  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection "superhtml")
    :major-modes '(html-mode mhtml-mode web-mode)
    :server-id 'superhtml)))

(use-package lsp-ui
  :after lsp-mode
  :custom
  (lsp-ui-doc-enable t)                 ;; Enable doc popup
  (lsp-ui-doc-show-with-cursor nil)     ;; Don't show doc on cursor hover (use K instead)
  (lsp-ui-doc-show-with-mouse t)        ;; Show doc on mouse hover
  (lsp-ui-doc-position 'at-point)       ;; Show doc at point
  (lsp-ui-sideline-enable t)            ;; Show sideline info
  (lsp-ui-sideline-show-diagnostics t)  ;; Show diagnostics in sideline
  (lsp-ui-sideline-show-hover nil)      ;; Don't show hover info in sideline
  (lsp-ui-sideline-show-code-actions t) ;; Show code actions in sideline
  (lsp-ui-peek-enable t))               ;; Enable peek feature

(use-package dap-mode
  :after lsp-mode
  :commands dap-debug
  :custom
  ;; Basic settings
  (dap-auto-configure-features '(sessions locals controls tooltip))
  (dap-ui-buffer-configurations
   '(("*dap-ui-sessions*"
      (side . right) (slot . 1) (window-width . 0.33))
     ("*dap-ui-locals*"
      (side . right) (slot . 2) (window-width . 0.33))
     ("*dap-ui-breakpoints*"
      (side . left) (slot . 1) (window-width . 0.20))
     ("*dap-ui-repl*"
      (side . bottom) (slot . 1) (window-height . 0.25))))
  :config
  ;; Enable dap-ui for better debugging experience
  (dap-ui-mode 1)
  (dap-tooltip-mode 1)

  ;; Go debugging via delve
  (require 'dap-dlv-go)
  (require 'dap-gdb)
  (require 'dap-lldb))

(use-package format-all
   :hook (prog-mode . format-all-mode))

(use-package flymake
  :ensure nil          ;; This is built-in, no need to fetch it.
  :defer t
  :hook (prog-mode . flymake-mode)
  :custom
  (flymake-margin-indicators-string
   '((error "!»" compilation-error) (warning "»" compilation-warning)
     (note "»" compilation-info))))

(use-package sideline-flymake
  :hook (flymake-mode . sideline-mode)
  :custom
  (sideline-flymake-display-mode 'line) ;; Show errors on the current line
  (sideline-backends-right '(sideline-flymake)))

(use-package flymake-collection
  :hook (after-init . flymake-collection-hook-setup)
  :config
  ;; Configure specific linters per mode (similar to nvim-lint)
  (push '(sh-mode flymake-collection-shellcheck) flymake-collection-config)
  (push '(bash-ts-mode flymake-collection-shellcheck) flymake-collection-config)
  (push '(python-mode flymake-collection-pylint) flymake-collection-config)
  (push '(python-ts-mode flymake-collection-pylint) flymake-collection-config)
  (push '(go-mode flymake-collection-golangci-lint) flymake-collection-config)
  (push '(go-ts-mode flymake-collection-golangci-lint) flymake-collection-config)
  (push '(yaml-mode flymake-collection-yamllint) flymake-collection-config)
  (push '(yaml-ts-mode flymake-collection-yamllint) flymake-collection-config))

(use-package yasnippet-snippets
  :hook (prog-mode . yas-minor-mode))

(use-package treesit-auto
  :custom
  (treesit-auto-install nil)  ;; Don't download parsers - Nix provides them
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

(use-package treesit-fold
  :after evil
  :hook ((prog-mode . treesit-fold-mode)
         (prog-mode . treesit-fold-indicators-mode))
  :config
  ;; Fold indicator settings (like statuscol.nvim)
  (setq treesit-fold-indicators-fringe 'left-fringe)
  (setq treesit-fold-indicators-priority 100)

  ;; Evil keybindings for folding (matching Vim defaults)
  (evil-define-key 'normal 'global
    "za" 'treesit-fold-toggle      ;; Toggle fold at point
    "zc" 'treesit-fold-close       ;; Close fold at point
    "zo" 'treesit-fold-open        ;; Open fold at point
    "zR" 'treesit-fold-open-all    ;; Open all folds (like nvim-ufo)
    "zM" 'treesit-fold-close-all   ;; Close all folds (like nvim-ufo)
    "zr" 'treesit-fold-open-recursively  ;; Open fold recursively
    "zm" 'treesit-fold-close-all)) ;; Close all folds

(use-package eldoc
  :ensure nil                                ;; This is built-in, no need to fetch it.
  :config
  (setq eldoc-idle-delay 0)                  ;; Automatically fetch doc help
  (setq eldoc-echo-area-use-multiline-p nil) ;; We use the "K" floating help instead
                                             ;; set to t if you want docs on the echo area
  (setq eldoc-echo-area-display-truncation-message nil)
  :init
  (global-eldoc-mode))

(use-package eldoc-box
  :ensure t
  :defer t)

(use-package nix-mode
  :mode "\\.nix\\'")

(use-package lua-mode
  :mode "\\.lua\\'") ;; Only start in a lua file

(use-package rust-mode
  :mode "\\.rs\\'")

(use-package go-mode
  :mode "\\.go\\'")

(use-package dotenv-mode
  :defer t
  :ensure t
  :config)

(use-package web-mode
  :ensure t
  :mode
  (("\\.phtml\\'" . web-mode)
   ("\\.php\\'" . web-mode)
   ("\\.tpl\\'" . web-mode)
   ("\\.[agj]sp\\'" . web-mode)
   ("\\.as[cp]x\\'" . web-mode)
   ("\\.erb\\'" . web-mode)
   ("\\.mustache\\'" . web-mode)
   ("\\.djhtml\\'" . web-mode)))

(use-package eat
  :hook ('eshell-load-hook #'eat-eshell-mode))

(use-package vterm
  :commands vterm
  :config
  ;; (setq vterm-shell "zsh")                       ;; Set this to customize the shell to launch
  (setq vterm-max-scrollback 10000))

(use-package magit
  :defer
  :custom (magit-diff-refine-hunk (quote all)) ;; Shows inline diff
  :config (define-key transient-map (kbd "<escape>") 'transient-quit-one) ;; Make escape quit magit prompts
  )

(use-package diff-hl
  :hook ((dired-mode         . diff-hl-dired-mode-unless-remote)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  :init (global-diff-hl-mode))

(use-package smerge-mode
  :ensure nil
  :defer t
  :bind (:map smerge-mode-map
              ("C-c ^ u" . smerge-keep-upper)  ;; Keep the changes from the upper version.
              ("C-c ^ l" . smerge-keep-lower)  ;; Keep the changes from the lower version.
              ("C-c ^ n" . smerge-next)        ;; Move to the next conflict.
              ("C-c ^ p" . smerge-previous)))  ;; Move to the previous conflict.

(use-package blamer
  :defer 20
  :custom
  (blamer-idle-time 0.3)
  (blamer-min-offset 70)
  :config
  (global-blamer-mode 1))

(use-package corfu
  ;; Optional customizations
  :custom
  (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
  (corfu-auto t)                 ;; Enable auto completion
  (corfu-auto-prefix 2)          ;; Minimum length of prefix for auto completion.
  (corfu-popupinfo-mode t)       ;; Enable popup information
  (corfu-popupinfo-delay 0.5)    ;; Lower popup info delay to 0.5 seconds from 2 seconds
  (corfu-separator ?\s)          ;; Orderless field separator, Use M-SPC to enter separator
  ;; (corfu-quit-at-boundary nil)   ;; Never quit at completion boundary
  ;; (corfu-quit-no-match nil)      ;; Never quit, even if there is no match
  ;; (corfu-on-exact-match nil)     ;; Configure handling of exact matches
  ;; (corfu-scroll-margin 5)        ;; Use scroll margin
  (completion-ignore-case t)

  ;; Emacs 30 and newer: Disable Ispell completion function.
  ;; Try `cape-dict' as an alternative.
  (text-mode-ispell-word-completion nil)

  ;; Enable indentation+completion using the TAB key.
  ;; `completion-at-point' is often bound to M-TAB.
  (tab-always-indent 'complete)

  (corfu-preview-current 'insert) ;; Auto-insert when navigating (like blink.cmp auto_insert)
  (corfu-preselect 'first)        ;; Preselect first candidate so TAB selects it immediately
  ;; Recommended: Enable Corfu globally.  This is recommended since Dabbrev can
  ;; be used globally (M-/).  See also the customization variable
  ;; `global-corfu-modes' to exclude certain modes.
  :bind
  (:map corfu-map
        ("TAB" . corfu-next)
        ([tab] . corfu-next)
        ("S-TAB" . corfu-previous)
        ([backtab] . corfu-previous)
        ("RET" . corfu-insert)
        ([return] . corfu-insert))
  :init
  (global-corfu-mode)
  (corfu-popupinfo-mode t))

(use-package nerd-icons-corfu
  :after corfu
  :init (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

(use-package cape
  :after corfu
  :init
  ;; Add to the global default value of `completion-at-point-functions' which is
  ;; used by `completion-at-point'.  The order of the functions matters, the
  ;; first function returning a result wins.  Note that the list of buffer-local
  ;; completion functions takes precedence over the global list.

  ;; The functions that are added later will be the first in the list
  (add-hook 'completion-at-point-functions #'cape-dabbrev) ;; Complete word from current buffers
  (add-hook 'completion-at-point-functions #'cape-dict) ;; Dictionary completion
  (add-hook 'completion-at-point-functions #'cape-file) ;; Path completion
  (add-hook 'completion-at-point-functions #'cape-elisp-block) ;; Complete elisp in Org or Markdown mode
  (add-hook 'completion-at-point-functions #'cape-keyword) ;; Keyword completion

  ;;(add-hook 'completion-at-point-functions #'cape-abbrev) ;; Complete abbreviation
  ;;(add-hook 'completion-at-point-functions #'cape-history) ;; Complete from Eshell, Comint or minibuffer history
  ;;(add-hook 'completion-at-point-functions #'cape-line) ;; Complete entire line from current buffer
  ;;(add-hook 'completion-at-point-functions #'cape-elisp-symbol) ;; Complete Elisp symbol
  ;;(add-hook 'completion-at-point-functions #'cape-tex) ;; Complete Unicode char from TeX command, e.g. \hbar
  ;;(add-hook 'completion-at-point-functions #'cape-sgml) ;; Complete Unicode char from SGML entity, e.g., &alpha
  ;;(add-hook 'completion-at-point-functions #'cape-rfc1345) ;; Complete Unicode char using RFC 1345 mnemonics
  )

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package vertico
  :init
  (vertico-mode))

(savehist-mode) ;; Enables save history mode

(use-package marginalia
  :after vertico
  :init
  (marginalia-mode))

(use-package nerd-icons-completion
  :after marginalia
  :config
  (nerd-icons-completion-mode)
  :hook
  ('marginalia-mode-hook . 'nerd-icons-completion-marginalia-setup))

(use-package copilot-chat)

(use-package claude-code)

(defun rdmacs/org-font-setup ()
  ;; Replace list hyphen with dot
  (font-lock-add-keywords 'org-mode
                          '(("^ *\\([-]\\) "
                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

  ;; Set faces for heading levels
  (dolist (face '((org-level-1 . 1.2)
                  (org-level-2 . 1.1)
                  (org-level-3 . 1.05)
                  (org-level-4 . 1.0)
                  (org-level-5 . 1.1)
                  (org-level-6 . 1.1)
                  (org-level-7 . 1.1)
                  (org-level-8 . 1.1)))
    (set-face-attribute (car face) nil :font "SFProDisplay Nerd Font" :weight 'regular :height (cdr face)))

  ;; Ensure that anything that should be fixed-pitch in Org files appears that way
  (set-face-attribute 'org-block nil    :foreground nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-table nil    :inherit 'fixed-pitch)
  (set-face-attribute 'org-formula nil  :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil     :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-table nil    :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil  :inherit 'fixed-pitch)
  (set-face-attribute 'line-number nil :inherit 'fixed-pitch)
  (set-face-attribute 'line-number-current-line nil :inherit 'fixed-pitch))

;; set up  fonts
(use-package org
  :ensure nil
  :custom
  (org-edit-src-content-indentation 4) ;; Set src block automatic indent to 4 instead of 2.
  (org-return-follows-link t)   ;; Sets RETURN key in org-mode to follow links
  :hook
  (org-mode . org-indent-mode) ;; Indent text
  ;; The following prevents <> from auto-pairing when electric-pair-mode is on.
  ;; Otherwise, org-tempo is broken when you try to <s TAB...
  (org-mode . (lambda ()
                (setq-local electric-pair-inhibit-predicate
                            `(lambda (c)
                               (if (char-equal c ?<) t (,electric-pair-inhibit-predicate c))))))
  (rdmacs/org-font-setup))

(use-package toc-org
  :commands toc-org-enable
  :hook (org-mode . toc-org-mode))

(use-package org-superstar
  :after org
  :hook (org-mode . org-superstar-mode))

(use-package org-tempo
  :ensure nil
  :after org)

(defun rdmacs/org-mode-visual-fill ()
  (setq visual-fill-column-width 100
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(use-package visual-fill-column
  :hook (org-mode . rdmacs/org-mode-visual-fill))

(use-package consult
  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook (completion-list-mode . consult-preview-at-point-mode)
  :init
  ;; Optionally configure the register formatting. This improves the register
  ;; preview for `consult-register', `consult-register-load',
  ;; `consult-register-store' and the Emacs built-ins.
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  ;; This adds thin lines, sorting and hides the mode line of the window.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)
  :config
  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key "M-.")
  ;; (setq consult-preview-key '("S-<down>" "S-<up>"))

  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  ;; (consult-customize
  ;; consult-theme :preview-key '(:debounce 0.2 any)
  ;; consult-ripgrep consult-git-grep consult-grep
  ;; consult-bookmark consult-recent-file consult-xref
  ;; consult--source-bookmark consult--source-file-register
  ;; consult--source-recent-file consult--source-project-recent-file
  ;; :preview-key "M-."
  ;; :preview-key '(:debounce 0.4 any))

  ;; By default `consult-project-function' uses `project-root' from project.el.
  ;; Optionally configure a different project root function.
   ;;;; 1. project.el (the default)
  ;; (setq consult-project-function #'consult--default-project--function)
   ;;;; 2. vc.el (vc-root-dir)
  ;; (setq consult-project-function (lambda (_) (vc-root-dir)))
   ;;;; 3. locate-dominating-file
  ;; (setq consult-project-function (lambda (_) (locate-dominating-file "." ".git")))
   ;;;; 4. projectile.el (projectile-project-root)
  (autoload 'projectile-project-root "projectile")
  (setq consult-project-function (lambda (_) (projectile-project-root)))
   ;;;; 5. No project support
  ;; (setq consult-project-function nil)
  )

(use-package helpful
  :bind
  ;; Note that the built-in `describe-function' includes both functions
  ;; and macros. `helpful-function' is functions only, so we provide
  ;; `helpful-callable' as a drop-in replacement.
  ("C-h f" . helpful-callable)
  ("C-h v" . helpful-variable)
  ("C-h k" . helpful-key)
  ("C-h x" . helpful-command)
  )

(use-package diminish)

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package ws-butler
  :config 
  (ws-butler-global-mode 1))

(use-package neotree
  :ensure t
  :custom
  (neo-show-hidden-files t)                ;; By default shows hidden files (toggle with H)
  (neo-theme 'nerd)                        ;; Set the default theme for Neotree to 'nerd' for a visually appealing look.
  (neo-vc-integration '(face char))        ;; Enable VC integration to display file states with faces (color coding) and characters (icons).
  :defer t                                 ;; Load the package only when needed to improve startup time.
  :config
  (setq neo-theme 'nerd-icons))         ;; Set the theme to 'nerd-icons' if nerd fonts are available.

;; Make gc pauses faster by decreasing the threshold.
(setq gc-cons-threshold (* 2 1000 1000))
;; Increase the amount of data which Emacs reads from the process
(setq read-process-output-max (* 1024 1024)) ;; 1mb

;; (add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

;; (require 'start-multiFileExample)

;; (start/hello)

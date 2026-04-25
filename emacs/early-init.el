;;; early-init.el --- Early initialization -*- lexical-binding: t; -*-

;; Make startup faster by reducing the frequency of garbage collection. This will be set back when startup finishes.
;; We also increase Read Process Output Max so Emacs can read more data.
;; Set garbage collector (from doom emacs)
;; About 0.02 faster
(setq gc-cons-threshold (* 1024 1024 128)  ;; 128mb
	  gc-cons-percentage 1.0) ;; Disable the dynamic percentage trigger to ensure GC frequency is fixed.

;; Unset file-name-handler-alist
;; About 0.07 faster
(defvar last-file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)
(add-hook 'after-init-hook
          (lambda ()
            (setq file-name-handler-alist last-file-name-handler-alist)))

;; Fix seq library compatibility issue in Emacs 30.2
;; Must be loaded early to prevent cl-no-applicable-method errors
(require 'seq)

;; Fix white flash on startup
;; Match catppuccin-mocha palette so there's no color shift when the theme loads.
;; Skipped only in terminal mode where these GUI colors don't apply.
(unless (not initial-window-system)
  (setq default-frame-alist '((foreground-color . "#cdd6f4")    ; mocha text
                              (background-color . "#1e1e2e")))) ; mocha base


;; Package quickstart for faster startup
;; Precomputes a single autoload file instead of scanning on every launch
(setq package-quickstart-file (expand-file-name "package-quickstart.el" "~/.cache/emacs/"))
(setq package-quickstart t)

;; Disable UI elements before UI initialization.
;; For faster startup times. It gives 0.05 sec.
(setq menu-bar-mode nil)         ;; Disable the menu bar
(setq tool-bar-mode nil)         ;; Disable the tool bar
(push '(vertical-scroll-bars) default-frame-alist) ;; Disable the scroll bar


;;; early-init.el ends here

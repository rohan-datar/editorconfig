;;; early-init.el --- Early initialization -*- lexical-binding: t; -*-

;;; Commentary:
;; Runs before init.el and package initialization.
;; Keep this minimal — only settings that must take effect early.

;;; Code:

;; Package quickstart for faster startup
;; Precomputes a single autoload file instead of scanning on every launch
(setq package-quickstart t)

;; Disable UI chrome early to prevent momentary flash
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; Load theme early to avoid flash of default colors
(require 'catppuccin-theme)
(load-theme 'catppuccin t)

;;; early-init.el ends here

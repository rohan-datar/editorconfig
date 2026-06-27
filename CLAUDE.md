# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Nix flake that manages editor configurations for both Neovim and Emacs. The flake uses:
- **NixCats** for Neovim configuration management
- **emacs-overlay** for Emacs package management with org-babel for configuration tangling

## Building and Running

### Neovim

Build and run Neovim configurations:
```bash
# Build the full configuration
nix build .#nvim-full

# Build the minimal configuration
nix build .#nvim-minimal

# Build the test configuration (allows live editing)
nix build .#nvim-test

# Run directly
nix run .#nvim-full
nix run .#nvim-minimal
nix run .#nvim-test
```

### Emacs

Build and run Emacs configurations:
```bash
# Build Emacs with all packages
nix build .#rdmacs

# Run Emacs
nix run .#rdmacs

# Run Emacs in isolated test environment with live config tangling
# (run from flake directory, or set RDMACS_CONFIG=path/to/emacs.org)
nix run .#rdmacs-test
```

### General Flake Commands

```bash
# Check flake evaluation (runs in CI)
nix flake check --all-systems

# Update all flake inputs
nix flake update

# Show flake outputs
nix flake show
```

## Architecture

### Flake Structure

The main `flake.nix` uses flake-parts to modularize configuration:
- `args.nix` - Configures nixpkgs with overlays and system settings
- `nvim/` - NixCats-based Neovim configuration
- `emacs/` - emacs-overlay based Emacs configuration

### Neovim Configuration (nvim/)

NixCats organizes Neovim config using:
1. **categories.nix** - Defines plugin categories and their dependencies:
   - `startupPlugins` - Loaded at startup
   - `optionalPlugins` - Lazy-loaded via lze/lz.n
   - `lspsAndRuntimeDeps` - Language servers, formatters, compilers, debuggers

2. **packages.nix** - Defines three build profiles by enabling/disabling categories:
   - `full` - All categories enabled (default)
   - `minimal` - Only core, editing, and git
   - `test` - Like full but with `wrapRc = false` for live editing

3. **lua/** directory structure:
   - `config/` - Core configuration modules
   - `lsp/` - LSP configurations
   - `plugins/` - Plugin-specific configurations
   - `nixCatsUtils/` - NixCats integration utilities
   - `fallback.lua` - Configuration loaded when not in NixCats environment

### Emacs Configuration (emacs/)

1. **emacs.org** - Literate configuration file containing all Emacs setup
   - Tangled to elisp at eval time using `inputs.org-babel.lib.tangleOrgBabel`
     and passed directly to the wrapper's `configFile` option (no IFD)

2. **default.nix** - emacs-overlay + nix-wrapper-modules configuration:
   - `rdmacs-unwrapped` - Base Emacs with packages via `emacsWithPackages`
   - `rdmacs` - Wrapped version via `nix-wrapper-modules`:
     - Sets `userDirectory = "~/.cache/emacs"` so packages write to a writable location
     - Provides `bin/emacs` and `bin/emacsclient` on all platforms
     - On Darwin, also creates `Emacs.app` and `Emacsclient.app` bundles for Spotlight/Raycast
   - `rdmacs-test` - Live-tangling wrapper for config iteration
   - Package versions come from emacs-overlay (updated frequently)

### Key Design Decisions

**Neovim:**
- Uses lazy-loading via lze for optional plugins
- Categories allow building different profiles (full/minimal/test)
- Test profile allows live editing without rebuilds
- All LSPs/tools packaged together with editor

**Emacs:**
- Configuration lives in org-mode for literate programming
- Packages come from emacs-overlay (stable, widely-used)
- Uses emacs-pgtk for native Wayland support
- Single `rdmacs` package works on all platforms; on Darwin it includes app bundles
- Test wrapper tangles config on-the-fly for live iteration without rebuilding

### Adding Packages

**Neovim:**
1. Add plugin input to `flake.nix` if not in nixpkgs
2. Add to appropriate category in `nvim/categories.nix`
3. Create config file in `nvim/lua/plugins/`
4. Enable category in desired profile in `nvim/packages.nix`

**Emacs:**
1. Add package to the `withPackages` list in `emacs/default.nix`
2. Add configuration to `emacs/emacs.org`
3. Run `nix run .#rdmacs-test` to test, then rebuild with `nix build .#rdmacs`

## CI/CD

GitHub Actions workflows:
- **check.yml** - Runs `nix flake check --all-systems` on push
- **update.yml** - Automated flake input updates (Tuesdays/Thursdays at 9PM UTC)

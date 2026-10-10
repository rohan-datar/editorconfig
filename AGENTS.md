# Repository Guidelines

## Project Overview

This Nix flake packages personal Emacs (`rdmacs`), Neovim, and Helix configurations with their plugins and external tools. It is editor configuration, not an EditorConfig parser or a conventional application service.

## Architecture & Data Flow

- `flake.nix` uses flake-parts to import shared arguments, formatting, and editor modules. `args.nix` injects per-system `pkgs` with Emacs, Org Babel, and local overlays. Dependencies flow through Nix module/function arguments, not a DI container.
- All editors use `nix-wrapper-modules`: locked inputs and Nix package declarations become wrapped binaries, configuration, plugins, and runtime tool paths.
- **Neovim:** `nvim/default.nix` selects a profile; `nvim/specs.nix` defines plugin categories, tools, and `info.cats` metadata. `nvim/init.lua` initializes `_G.nixInfo`, then loads `fallback`, `config`, and `plugins`. `lze` specifications use `for_cat` gates and lazy triggers; LSP registration uses `lzextras` and native `vim.lsp.config`/`enable`. Non-Nix fallback uses `vim.pack.add`, not paq or packer.
- **Emacs:** `emacs/default.nix` tangles `emacs/emacs.org` through Org Babel at Nix evaluation time, without import-from-derivation. It combines the resulting Lisp, `early-init.el`, package declarations, and runtime dependencies. `rdmacs-test` instead tangles a local Org file at launch. Writable state lives under `~/.cache/emacs`; test mode does not isolate all user state.
- **Helix:** `helix/default.nix` constructs shared settings with minimal/full tool profiles. Minimal bundles only `nixd` and `nixfmt`; full adds development tools and the shared `texliveCombined` output. `helix` aliases full, not minimal.

## Key Directories

- `nvim/lua/config/`: options and general mappings; `plugins/`: feature-specific setup; `lsp/`: server configuration and attachment mappings.
- `emacs/`: literate Lisp source, package/overlay construction, and macOS launcher templates.
- `helix/`: declarative editor, language-server, formatter, and profile configuration.
- `.github/workflows/`: Linux/macOS flake checks and scheduled lockfile-update PRs.

## Development Commands

Run from the repository root; select outputs explicitly because no default package/app or development shell is declared.

```sh
# Build the affected editor; full profiles can pull large tool/TeX closures.
nix build --no-link .#nvim-minimal
nix build --no-link .#rdmacs
nix build --no-link .#helix-minimal

# Launch configuration or inspect runtime health.
nix run .#helix-minimal -- flake.nix
nix run .#helix-minimal -- --health nix
RDMACS_CONFIG="$PWD/emacs/emacs.org" nix run .#rdmacs-test
nix shell .#nvim-test -c nvim-test

# Format/lint, evaluation-only validation, and CI-equivalent checks.
nix fmt
nix fmt -- --fail-on-change
nix -Lv flake check --no-build
nix -Lv flake check

# Focused check; replace x86_64-linux with the target system.
nix build --no-link .#checks.x86_64-linux.helix-minimal
```

`nvim-full` and `helix-full` are workstation alternatives. `nvim-test` uses `vim.fn.stdpath("config")`, not this checkout automatically; full/minimal embed the repository configuration. `rdmacs-test` permits local Lisp iteration, but package changes still require rebuilding. Prefer foreground launches for diagnostics: `rdmacs-test.sh` detaches and discards output; `RDMACS_FLAKE_DIR` overrides its default `~/editorconfig` checkout.

## Code Conventions & Common Patterns

- Use `nix fmt`: treefmt runs nixfmt, deadnix, statix fixes, StyLua, ShellCheck, shfmt (two spaces), and keep-sorted. Preserve marked `keep-sorted` blocks. Formatting can rewrite files; no Org/Elisp formatter is configured. `actionlint` is provisioned but not wired into treefmt.
- Keep Neovim feature modules as returned `lze` specification tables with `for_cat`, lazy triggers, and setup callbacks. Add matching Nix plugin/tool declarations and category metadata; do not introduce a second plugin manager. Lua follows tabs, double quotes, local helpers, and descriptive keymaps.
- Use `nixInfo(default, ...path)` for metadata/category lookup. Preserve minimal/full gates: `test` gets full categories. Outside Nix, defaults matter; the ordinary LSP startup gate defaults to false.
- Edit Emacs Lisp in the relevant `emacs.org` source block, not generated `emacs.el`/`init.el`. Keep lexical binding and `use-package` conventions (`:init`, `:config`, `:hook`, `:after`, deferred commands). Personal interactive functions use `rdmacs/`; internal helpers commonly use `rdmacs--`.
- State is editor-local: `vim.opt`/`vim.g`, buffer options, autocmds, and small closures in Lua; hooks/advice and buffer-local variables in Lisp. Async work uses editor/package callbacks, deferred LSP, and compilation APIs, not a custom scheduler.
- Preserve targeted availability guards (`pcall`, executable/platform checks, optional private Org checkout) and useful diagnostics. Lisp uses `user-error` for invalid interaction and `unwind-protect` for temporary-state cleanup. Avoid blanket error suppression.

## Important Files

- `flake.nix` / `flake.lock`: input declarations and pinned dependencies; `args.nix`: system package injection and overlay order; `formatter.nix`: formatting/lint policy.
- `nvim/specs.nix` / `nvim/default.nix`: category/profile contracts; `nvim/init.lua`: startup; `nvim/lua/plugins/init.lua`: imports and category handler.
- `emacs/emacs.org` / `emacs/early-init.el`: main/early startup; `emacs/packages.nix`: Lisp packages and tools; `emacs/overlay.nix`: custom packages and Ghostel overrides.
- `helix/default.nix`: both profiles and the explicit smoke check.

Treat source as authoritative. Saving repository `emacs.org` is not guaranteed to auto-tangle; use the test launcher or rebuild.

## Runtime/Tooling Preferences

Use Nix with flakes and `nix-command` enabled; Nix is the dependency/package manager. No repository Node/Bun package-manager workflow exists. Provision editor plugins, language servers, and formatters through the existing Nix declarations. Keep platform gates: Darwin Swift integration expects system Xcode/sourcekit-lsp, and app-bundle construction uses `/usr/bin/osacompile`. Preserve the `emacsPackagesFor` override ordering and Neovim's disabled Ruby-host packaging guard.

## Testing & QA

There is no repository-owned unit-test framework or coverage threshold. `*-test` outputs are iteration profiles, not automated suites. CI runs `nix -Lv flake check` on Linux/macOS; it does not explicitly build every editor profile or run formatting, and Markdown-only pushes are excluded.

The explicit `checks.<system>.helix-minimal` verifies startup/Nix health, requires `nixd` and `nixfmt`, and rejects TeX dependencies in the minimal closure. For changes, build the affected profile and exercise its actual startup/feature path; flake evaluation alone cannot prove Lua/Lisp behavior. Keep minimal tooling separate from workstation/TeX additions. Never use private `~/Documents/Org` notes as test fixtures.

# EditorConfig

This repository is a Nix flake that builds my Neovim, Emacs, and Helix configurations.

## Structure
- `flake.nix`, `args.nix`, `formatter.nix`: flake wiring, overlays, and treefmt setup.
- `nvim/`: Neovim config using nix-wrapper-modules (plugin categories and runtime tools in `nvim/specs.nix`, profiles in `nvim/default.nix`, Lua under `nvim/lua/`).
- `emacs/`: Emacs overlay build with a literate config in `emacs/emacs.org` and packaging in `emacs/default.nix`.
- `rdmacs-test.sh`: detached helper to launch the Emacs iteration profile from Raycast/launchers.
- `helix/`: Shared Helix config using nix-wrapper-modules, with minimal (server) and full (workstation) tool profiles.

## Packages
- `.#nvim-full`: Full Neovim profile with all categories enabled.
- `.#nvim-minimal`: Lean Neovim profile with core editing and git.
- `.#nvim-test`: Full-category Neovim profile that loads the user config at `vim.fn.stdpath("config")` for live editing; it does not automatically load this checkout.
- `.#rdmacs`: Emacs with init-directory baked in. Provides `bin/emacs` and `bin/emacsclient` on all platforms; on Darwin also includes `Emacs.app` and `Emacsclient.app` bundles for Spotlight/Raycast.
- `.#rdmacs-test`: Emacs iteration launcher that tangles a local Org config on launch; package dependency changes still require rebuilding.
- `.#helix-minimal`: Server profile. Bundles only `nixd` and `nixfmt` as extra runtime tools, with Nix language configuration. No full development toolchain or TeX.
- `.#helix-full`: Workstation profile. Adds language servers, linters, formatters, debuggers, and the shared Emacs TeX toolchain. Adds Swift formatting on Darwin; `sourcekit-lsp` comes from Xcode.
- `.#helix`: Compatibility alias for `.#helix-full`, **not** the minimal profile.

## Trying Helix
```bash
# Servers and a lightweight first run
nix run .#helix-minimal -- flake.nix
nix run .#helix-minimal -- --health nix
nix build .#helix-minimal

# Workstations (includes TeX)
nix run .#helix-full -- flake.nix
nix build .#helix-full

# Minimal smoke check; replace x86_64-linux with your target system
# (for example, aarch64-darwin). No full-profile or TeX build.
nix build --no-link .#checks.x86_64-linux.helix-minimal
```

Both profiles share default keybindings, Catppuccin Mocha with a transparent background,
relative line numbers, and common editing settings. Nix formatting on save is enabled
in both profiles; `:format` also runs `nixfmt` manually.
Edit `helix/default.nix`, then rerun the selected profile to rebuild.
The wrapper supplies its own configuration without modifying `~/.config/helix`.
The minimal profile retains Helix's built-in grammars and language defaults for other
languages, but does not bundle their external tools. It adds only Nix-specific overrides.
The full profile also configures Lua, Rust, Go, C/C++, Bash, Python, web languages, and
LaTeX (`texlab` with `latexmk` on save and `chktex`).
For a first-time introduction, launch `nix run .#helix-minimal -- --tutor`.

## Non-Intuitive Bits
- Neovim profiles are defined in `nvim/default.nix`; categories and tools are in `nvim/specs.nix`. Full/minimal embed the repository config; `test` keeps the wrapper-provided plugins/tools but allows normal user configuration. Run it with `nix shell .#nvim-test -c nvim-test`.
- Emacs config lives in `emacs/emacs.org`. The regular package tangles it to Lisp at Nix evaluation time without import-from-derivation; `rdmacs-test` tangles at launch. Edit the Org source or `emacs/early-init.el`, not generated Lisp. Saving the repository Org file is not guaranteed to auto-tangle.
- Run `nix run .#rdmacs-test` from the repository root, or set `RDMACS_CONFIG=/path/to/emacs.org` to try alternate configs. The launcher uses a temporary init directory, but the config still writes to `~/.cache/emacs` and can use private `~/Documents/Org` notes; user state is not fully isolated.
- Formatting/linting is via `nix fmt` (nixfmt, stylua, shfmt, shellcheck, deadnix, statix, keep-sorted); it can rewrite files. Use `nix fmt -- --fail-on-change` for a check-only run. Keep `# keep-sorted` blocks ordered. No Org/Elisp formatter is configured.
- CI runs `nix -Lv flake check` on Linux and macOS, without `--all-systems`. It does not explicitly build every editor profile or run formatting; Markdown-only pushes are excluded.
- There is no repository-owned unit-test suite or coverage threshold. The `*-test` packages are iteration profiles, not test runners. The explicit Helix minimal check verifies runtime Nix health and rejects TeX dependencies in its closure; build and exercise other affected profiles separately.

## Troubleshooting
- `nix` not found in GUI launches: ensure the Nix profile script is sourced; `rdmacs-test.sh` handles this for Raycast.
- Neovim edits not reflected: rebuild `.#nvim-full`/`.#nvim-minimal` for checkout changes, or use `.#nvim-test` with changes in the user config directory for live iteration.
- Emacs changes not picked up: edit `emacs/emacs.org` and run `.#rdmacs-test` or rebuild `.#rdmacs`.
- Emacs launcher fails silently: run `nix run .#rdmacs-test` in the foreground to see diagnostics. `rdmacs-test.sh` discards output and defaults to `~/editorconfig`; override its checkout with `RDMACS_FLAKE_DIR`.
- Formatter failures: run `nix fmt` from the repo root and keep sorted blocks intact.

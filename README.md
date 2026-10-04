# EditorConfig 

This repository is a Nix flake that builds my Neovim, Emacs, and Helix configurations.

## Structure
- `flake.nix`, `args.nix`, `formatter.nix`: flake wiring, overlays, and treefmt setup.
- `nvim/`: NixCats-based Neovim config (categories in `nvim/categories.nix`, profiles in `nvim/packages.nix`, Lua under `nvim/lua/`).
- `emacs/`: Emacs overlay build with a literate config in `emacs/emacs.org` and packaging in `emacs/default.nix`.
- `rdmacs-test.sh`: helper to launch the Emacs test build from Raycast/launchers.
- `helix/`: Shared Helix config using nix-wrapper-modules, with minimal (server) and full (workstation) tool profiles.

## Packages
- `.#nvim-full`: Full Neovim profile with all categories enabled.
- `.#nvim-minimal`: Lean Neovim profile with core editing and git.
- `.#nvim-test`: Neovim profile for live editing without rebuilds.
- `.#rdmacs`: Emacs with init-directory baked in. Provides `bin/emacs` and `bin/emacsclient` on all platforms; on Darwin also includes `Emacs.app` and `Emacsclient.app` bundles for Spotlight/Raycast.
- `.#rdmacs-test`: Emacs build that tangles on launch for faster iteration.
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

# Minimal smoke check on this Mac; no full-profile or TeX build
nix build .#checks.aarch64-darwin.helix-minimal
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
- Neovim profiles are defined in `nvim/packages.nix`. The `test` profile disables wrapper behavior to allow live editing.
- Emacs config lives in `emacs/emacs.org` and is tangled to elisp during builds. Avoid editing generated elisp directly.
- `rdmacs-test` runs Emacs in an isolated environment; set `RDMACS_CONFIG=/path/to/emacs.org` to try alternate configs.
- Formatting is via `nix fmt` (nixfmt, stylua, shfmt, deadnix, statix, keep-sorted). Keep `# keep-sorted` blocks ordered.
- CI runs `nix flake check --all-systems`.

## Troubleshooting
- `nix` not found in GUI launches: ensure the Nix profile script is sourced; `rdmacs-test.sh` handles this for Raycast.
- Neovim edits not reflected: use `.#nvim-test` for live changes or rebuild `.#nvim-full`/`.#nvim-minimal`.
- Emacs changes not picked up: edit `emacs/emacs.org` and run `.#rdmacs-test` or rebuild `.#rdmacs`.
- Formatter failures: run `nix fmt` from the repo root and keep sorted blocks intact.

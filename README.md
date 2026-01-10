# EditorConfig 

This repository is a Nix flake that builds my Neovim and Emacs configurations.

## Structure
- `flake.nix`, `args.nix`, `formatter.nix`: flake wiring, overlays, and treefmt setup.
- `nvim/`: NixCats-based Neovim config (categories in `nvim/categories.nix`, profiles in `nvim/packages.nix`, Lua under `nvim/lua/`).
- `emacs/`: Emacs overlay build with a literate config in `emacs/emacs.org` and packaging in `emacs/default.nix`.
- `rdmacs-test.sh`: helper to launch the Emacs test build from Raycast/launchers.

## Packages
- `.#nvim-full`: Full Neovim profile with all categories enabled.
- `.#nvim-minimal`: Lean Neovim profile with core editing and git.
- `.#nvim-test`: Neovim profile for live editing without rebuilds.
- `.#rdmacs`: Emacs with init-directory baked in. Provides `bin/emacs` and `bin/emacsclient` on all platforms; on Darwin also includes `Emacs.app` and `Emacsclient.app` bundles for Spotlight/Raycast.
- `.#rdmacs-test`: Emacs build that tangles on launch for faster iteration.

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

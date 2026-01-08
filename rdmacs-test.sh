#!/usr/bin/env bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title RDMacs Test
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🤖

# Source nix environment (needed when launched from Raycast/launchers)
if [[ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
  # shellcheck source=/dev/null
  source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
elif [[ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]]; then
  # shellcheck source=/dev/null
  source "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

FLAKE_DIR="${RDMACS_FLAKE_DIR:-$HOME/editorconfig}"

if [[ "$(uname)" == "Darwin" ]]; then
  # macOS: use osascript to fully detach from Raycast
  osascript -e "do shell script \"PATH='/nix/var/nix/profiles/default/bin:$PATH' nix run '$FLAKE_DIR#rdmacs-test' >/dev/null 2>&1 &\""
else
  # Linux: subshell with nohup
  (cd "$FLAKE_DIR" && nohup nix run .#rdmacs-test </dev/null >/dev/null 2>&1 &)
fi

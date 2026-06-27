-- Emacsclient launcher (background agent, no Dock icon).
-- Opens a frame on the running Emacs server; if no server is up,
-- launches Emacs.app and retries for up to ~30s.
--
-- This file is processed at build time by Nix (substituteInPlace) which
-- replaces the store path placeholder with the rdmacs derivation output. It
-- is then compiled into an app bundle with `osacompile` (see emacs/default.nix).

property emacsClientBin : "@out@/bin/emacsclient"
property emacsApp : "@out@/Applications/Emacs.app"

on openClient(argStr)
    try
        do shell script (quoted form of emacsClientBin & " -c -n" & argStr)
        return true
    on error
        return false
    end try
end openClient

on launchClient(argStr)
    if openClient(argStr) then return

    -- No server running: start Emacs.app, then poll until it accepts connections.
    do shell script "open " & quoted form of emacsApp
    set waited to 0
    repeat while waited < 30
        delay 1
        set waited to waited + 1
        if openClient(argStr) then return
    end repeat
end launchClient

-- IMPORTANT: use `on run` (NO parameter), not `on run argv`.
-- When a compiled applet is launched by Finder/Spotlight/LaunchServices with
-- no dropped documents, the run handler is called with the *current
-- application* object as its argument, NOT an empty list. A handler declared
-- as `on run argv` therefore receives a non-list; iterating it with
-- `repeat with arg in argv` throws and silently aborts the whole script before
-- the client ever runs -- which is exactly why the launcher did nothing.
-- Dropped files are handled separately by the `on open` handler below.
on run
    launchClient("")
end run

-- Called by LaunchServices when files are dropped onto the app.
on open fileList
    set argStr to ""
    repeat with f in fileList
        set argStr to argStr & " " & quoted form of (POSIX path of f)
    end repeat
    launchClient(argStr)
end open

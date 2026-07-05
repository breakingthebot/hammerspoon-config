# hammerspoon-config

Personal Hammerspoon automation for macOS — hotkey-driven window snapping, multi-monitor support, and an app launcher.

## Stack
- Lua (Hammerspoon's embedded scripting language)
- [Hammerspoon](https://www.hammerspoon.org/) — the macOS automation app that runs this config (not installed via a package manager; it's the runtime itself)

## Setup
1. Install Hammerspoon from https://www.hammerspoon.org/ (macOS only).
2. Clone this repo.
3. Copy or symlink `init.lua`, `config/`, and `src/` into `~/.hammerspoon/`, e.g.:
   ```bash
   ln -s /path/to/hammerspoon-config/init.lua ~/.hammerspoon/init.lua
   ln -s /path/to/hammerspoon-config/config ~/.hammerspoon/config
   ln -s /path/to/hammerspoon-config/src ~/.hammerspoon/src
   ```

## Environment Variables
None required.

## Running Locally
1. Open the Hammerspoon menu bar app and choose "Reload Config" (or run `hs.reload()` from the Hammerspoon console).
2. An on-screen alert reading "Hammerspoon config loaded" confirms it picked up the config.
3. Try the hotkeys listed below.

### Hotkeys (see `config/hotkeys.lua`)

| Hotkey | Action |
| --- | --- |
| `alt+ctrl+left` | Snap focused window to left half |
| `alt+ctrl+right` | Snap focused window to right half |
| `alt+ctrl+up` | Snap focused window to top half |
| `alt+ctrl+down` | Snap focused window to bottom half |
| `alt+ctrl+m` | Maximize focused window |
| `alt+ctrl+c` | Center focused window at 80% of screen size |
| `alt+ctrl+]` | Move focused window to the next screen, preserving relative size/position |
| `alt+ctrl+[` | Move focused window to the previous screen, preserving relative size/position |
| `alt+ctrl+shift+t` | Focus/launch Terminal (hide if already frontmost) |
| `alt+ctrl+shift+b` | Focus/launch Safari (hide if already frontmost) |
| `alt+ctrl+shift+e` | Focus/launch Visual Studio Code (hide if already frontmost) |

## Deployed
N/A — this is a local automation tool, not a hosted app.

## Architecture Notes
The window-geometry math (`src/window_manager.lua`) is written as pure functions that take a screen frame and a layout name and return a rectangle — no Hammerspoon API calls inside that calculation. A thin `apply()` wrapper is the only part that touches the real `hs.window` object. This split means the layout math can be unit tested with a plain Lua interpreter, without Hammerspoon installed, which matters here because Hammerspoon only runs on macOS.

`src/app_launcher.lua` follows the same idea: the logic branches on the state Hammerspoon reports (`isFrontmost`, whether the app is running at all) rather than hardcoding assumptions, and tests mock the `hs.application` calls to exercise all three branches (not running, running-but-background, running-and-frontmost).

`config/hotkeys.lua` is the single place that defines keybindings and the app list, so rebinding a key or adding an app never requires touching logic code in `src/` or `init.lua`.

Multi-monitor support (`translateFrame`, `nextScreenIndex`, `moveToScreen` in `src/window_manager.lua`) follows the same pure-function-plus-thin-wrapper split. `translateFrame` re-expresses a window's frame as a proportion of its current screen and reapplies that proportion to a target screen, so a half-screen window stays roughly half-screen after moving to a monitor with a different resolution or DPI. `nextScreenIndex` is the 1-based wraparound math for cycling through however many screens are connected. Both are pure and unit tested; only `moveToScreen` touches real `hs.screen`/`hs.window` objects.

## Notes
- Hammerspoon is macOS-only. This project was developed and unit-tested on Windows using a standalone Lua interpreter for the pure-logic pieces; the window-snapping and app-launching behavior itself has not been exercised inside actual Hammerspoon/macOS yet — verify hotkeys work as expected on your Mac after installing.
- `AGENTS.md` (build standards) is intentionally excluded from version control via `.gitignore`.

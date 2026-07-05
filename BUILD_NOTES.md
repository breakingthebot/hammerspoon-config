# Build Notes

Plain-English, append-only log of every iteration. See `CHANGELOG.md` for the terse technical version.

---

## Iteration 1 — 2026-07-05

### What was built
A Hammerspoon config for macOS that gives hotkey-driven window snapping and an app launcher. Window hotkeys snap the focused window to halves/thirds, maximize, or center it. App hotkeys focus an app if it's running, launch it if it's not, and hide it if it's already frontmost (so the same key toggles it in and out of view).

### File-by-file
- **`init.lua`** — the entry point Hammerspoon actually loads. Reads `config/hotkeys.lua` and wires each binding to `src/window_manager.lua` or `src/app_launcher.lua`.
- **`config/hotkeys.lua`** — every keybinding and the app list live here only, so rebinding a key or adding an app never touches logic code.
- **`src/window_manager.lua`** — `calculateFrame()` is pure math (screen rect + mode name → target rect), with no Hammerspoon calls in it. `apply()` is the thin wrapper that actually calls `hs.window`. Splitting it this way is what let the geometry get unit tested without Hammerspoon installed.
- **`src/app_launcher.lua`** — `focusOrLaunch()`: launches the app if not running, focuses it if running-but-background, hides it if already frontmost.
- **`tests/test_window_manager.lua`** — asserts each layout mode produces the right rectangle; also checks an unknown mode raises an error.
- **`tests/test_app_launcher.lua`** — mocks the global `hs.application` table to exercise all three branch cases.
- **`.gitignore`** — excludes `AGENTS.md` plus standard junk.
- **`LICENSE`** — MIT.
- **`README.md`** / **`CHANGELOG.md`** — setup instructions, hotkey table, architecture notes, v0.1.0 changelog entry.

Environment note: a standalone Lua interpreter was installed (via winget, since the dev machine is Windows) so the tests could actually run rather than just be written — both suites passed (9 + 3 assertions). Hammerspoon itself is macOS-only, so the actual window-snapping/hotkey behavior hasn't been exercised in the real app yet.

### Manual test steps
```bash
git clone https://github.com/breakingthebot/hammerspoon-config.git
ln -s "$(pwd)/hammerspoon-config/init.lua" ~/.hammerspoon/init.lua
ln -s "$(pwd)/hammerspoon-config/config" ~/.hammerspoon/config
ln -s "$(pwd)/hammerspoon-config/src" ~/.hammerspoon/src
```
Then in the Hammerspoon menu bar app: **Reload Config** → look for a "Hammerspoon config loaded" alert. Try `alt+ctrl+left/right/up/down/m/c` on a focused window, and `alt+ctrl+shift+t/b/e` to toggle Terminal/Safari/VS Code.

### Candidate next iterations considered
1. **Multi-monitor aware layouts** — Plain English: hotkeys snap windows relative to whichever screen the window is currently on, plus a "move window to next screen" hotkey. Benefit: most real setups have 2+ monitors and the current logic only reasons about one screen. Trade-off: adds screen-detection edge cases (different resolutions/DPI per monitor) to test. Interview answer: "I extended the geometry engine to be screen-relative instead of assuming a single display, which is the realistic case for any dev workstation."
2. **Config-driven user overrides** — Plain English: support an optional `~/.hammerspoon/user-config.lua` that overrides the repo defaults. Benefit: customize without diverging from the repo, so `git pull` doesn't clobber personal bindings. Trade-off: adds a merge-precedence layer to explain and test. Interview answer: "I separated defaults from user overrides so the config is both shareable and personally customizable, similar to how dotfiles managers layer configs."
3. **Grid/quarter layouts (2x2 corners)** — Plain English: add top-left/top-right/bottom-left/bottom-right quarter-screen hotkeys alongside the existing halves. Benefit: quarters are a very common tiling-WM pattern for 4-pane workflows. Trade-off: more hotkeys to remember; diminishing returns past a certain grid density. Interview answer: "I extended the same pure-function layout table with quarter-screen entries — zero new architecture, just more data."
4. **Menu bar status + reload-on-save** — Plain English: add a Hammerspoon menu bar icon showing config is loaded, and a file-watcher that auto-reloads config when any `.lua` file changes. Benefit: much faster iteration loop while tweaking hotkeys — no manual reload. Trade-off: a background file watcher is one more thing that can silently fail; needs a visible error state. Interview answer: "I added a dev-loop improvement — auto-reload on save — because iteration speed matters more for a personal tool like this than for production code."
5. **CI via GitHub Actions running the Lua test suite** — Plain English: on every push, GitHub Actions installs Lua and runs both test files automatically. Benefit: catches a broken geometry calculation or launcher regression before opening the Mac at all. Trade-off: slight setup overhead for a two-file test suite; more valuable once the test count grows. Interview answer: "I wired up CI early so test discipline doesn't erode as the config grows — it's cheap insurance for a tool I rely on daily."

### Chosen next iteration
_Pending — to be filled in once selected._

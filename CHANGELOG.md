# Changelog

All notable changes to this project are documented in this file.

## [Unreleased]

## [0.2.0] - 2026-07-05
### Added
- Multi-monitor support: `alt+ctrl+]` / `alt+ctrl+[` move the focused window to the next/previous screen, preserving its relative position and size (`translateFrame`, `nextScreenIndex`, `moveToScreen` in `src/window_manager.lua`).
- Unit tests for `translateFrame` (including cross-resolution translation) and `nextScreenIndex` wraparound in both directions.

## [0.1.0] - 2026-07-05
### Added
- Window manager: halves (left/right/top/bottom), thirds, maximize, and center layouts bound to `alt+ctrl+<arrow/m/c>`.
- App launcher: focus-or-launch-or-hide toggle for Terminal, Safari, and Visual Studio Code bound to `alt+ctrl+shift+<t/b/e>`.
- `config/hotkeys.lua` as the single source of truth for keybindings and the app list.
- Unit tests for window-geometry calculations (`tests/test_window_manager.lua`) and app-launcher branching logic (`tests/test_app_launcher.lua`), runnable with a plain Lua interpreter.
- MIT License.

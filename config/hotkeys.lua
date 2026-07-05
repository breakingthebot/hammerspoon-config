-- config/hotkeys.lua
-- Single source of truth for hotkey bindings and the app-launcher list.
-- Connects to: init.lua (reads this table to build hs.hotkey.bind calls)
-- Created: 2026-07-05

return {
  modifier = { "alt", "ctrl" },

  window = {
    { key = "left",  mode = "left-half" },
    { key = "right", mode = "right-half" },
    { key = "up",    mode = "top-half" },
    { key = "down",  mode = "bottom-half" },
    { key = "m",     mode = "maximize" },
    { key = "c",     mode = "center" },
  },

  -- Move the focused window to the next/previous display, preserving its
  -- relative position and size. No-op on a single-monitor setup.
  screens = {
    { key = "]", direction = 1 },
    { key = "[", direction = -1 },
  },

  -- App launcher uses its own modifier so it never collides with window keys.
  appModifier = { "alt", "ctrl", "shift" },

  apps = {
    { key = "t", name = "Terminal" },
    { key = "b", name = "Safari" },
    { key = "e", name = "Visual Studio Code" },
  },
}

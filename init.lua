-- init.lua
-- Hammerspoon entry point. Loads config and binds hotkeys for window
-- management and app launching.
-- Copy or symlink this file, config/, and src/ into ~/.hammerspoon/.
-- Connects to: config/hotkeys.lua, src/window_manager.lua, src/app_launcher.lua
-- Created: 2026-07-05

local hotkeys = require("config.hotkeys")
local windowManager = require("src.window_manager")
local appLauncher = require("src.app_launcher")

for _, binding in ipairs(hotkeys.window) do
  hs.hotkey.bind(hotkeys.modifier, binding.key, function()
    local win = hs.window.focusedWindow()
    windowManager.apply(win, binding.mode)
  end)
end

for _, app in ipairs(hotkeys.apps) do
  hs.hotkey.bind(hotkeys.appModifier, app.key, function()
    appLauncher.focusOrLaunch(app.name)
  end)
end

hs.alert.show("Hammerspoon config loaded")

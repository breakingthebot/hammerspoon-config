-- src/app_launcher.lua
-- Focus-or-launch logic for hotkey-bound applications.
-- Connects to: init.lua (bound to hotkeys), config/hotkeys.lua (app list)
-- Created: 2026-07-05

local M = {}

-- focusOrLaunch(appName)
-- If the app is running: focus it, or hide it if it's already frontmost
-- (so the same hotkey toggles the app in and out of view).
-- If it's not running: launch it.
function M.focusOrLaunch(appName)
  local app = hs.application.find(appName)

  if app then
    if app:isFrontmost() then
      app:hide()
    else
      app:activate(true)
    end
  else
    hs.application.launchOrFocus(appName)
  end
end

return M

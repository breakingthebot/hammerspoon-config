-- tests/test_app_launcher.lua
-- Unit tests for src/app_launcher.lua using a minimal mock of the Hammerspoon
-- `hs` global, since the real API only exists inside the Hammerspoon app.
-- Run from the repo root: lua tests/test_app_launcher.lua
-- Created: 2026-07-05

local calls = {}

_G.hs = {
  application = {
    find = function(name) return calls.mockApp end,
    launchOrFocus = function(name) calls.launched = name end,
  },
}

local appLauncher = require("src.app_launcher")
local passed = 0

-- Case 1: app not running -> launchOrFocus is called.
calls.mockApp = nil
calls.launched = nil
appLauncher.focusOrLaunch("Terminal")
assert(calls.launched == "Terminal", "expected launchOrFocus to be called for a non-running app")
passed = passed + 1

-- Case 2: app running, not frontmost -> activate is called.
local activated = false
calls.mockApp = {
  isFrontmost = function() return false end,
  activate = function(self, arg) activated = true end,
}
calls.launched = nil
appLauncher.focusOrLaunch("Safari")
assert(activated, "expected activate to be called for a running, non-frontmost app")
assert(calls.launched == nil, "launchOrFocus should not be called when the app is already running")
passed = passed + 1

-- Case 3: app running and frontmost -> hide is called.
local hidden = false
calls.mockApp = {
  isFrontmost = function() return true end,
  hide = function(self) hidden = true end,
}
appLauncher.focusOrLaunch("Visual Studio Code")
assert(hidden, "expected hide to be called for a running, frontmost app")
passed = passed + 1

print(string.format("test_app_launcher: %d assertions passed", passed))

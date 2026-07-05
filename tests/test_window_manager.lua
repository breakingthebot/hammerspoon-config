-- tests/test_window_manager.lua
-- Unit tests for the pure geometry calculations in src/window_manager.lua.
-- Run from the repo root: lua tests/test_window_manager.lua
-- Created: 2026-07-05

local windowManager = require("src.window_manager")

local screen = { x = 0, y = 0, w = 1000, h = 800 }

local function assertFrame(mode, expected)
  local frame = windowManager.calculateFrame(screen, mode)
  for k, v in pairs(expected) do
    assert(frame[k] == v, string.format("%s: expected %s=%s, got %s", mode, k, tostring(v), tostring(frame[k])))
  end
end

local passed = 0

assertFrame("left-half", { x = 0, y = 0, w = 500, h = 800 }); passed = passed + 1
assertFrame("right-half", { x = 500, y = 0, w = 500, h = 800 }); passed = passed + 1
assertFrame("top-half", { x = 0, y = 0, w = 1000, h = 400 }); passed = passed + 1
assertFrame("bottom-half", { x = 0, y = 400, w = 1000, h = 400 }); passed = passed + 1
assertFrame("left-third", { x = 0, y = 0, w = 1000 / 3, h = 800 }); passed = passed + 1
assertFrame("right-two-thirds", { x = 1000 / 3, y = 0, w = (2 * 1000) / 3, h = 800 }); passed = passed + 1
assertFrame("maximize", { x = 0, y = 0, w = 1000, h = 800 }); passed = passed + 1
assertFrame("center", { x = 100, y = 80, w = 800, h = 640 }); passed = passed + 1

local ok = pcall(windowManager.calculateFrame, screen, "not-a-real-mode")
assert(not ok, "expected calculateFrame to error on an unknown mode")
passed = passed + 1

print(string.format("test_window_manager: %d assertions passed", passed))

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

-- translateFrame: re-express a frame relative to a different screen,
-- including screens of a different resolution (simulates crossing monitors).
local fromScreen = { x = 0, y = 0, w = 1000, h = 800 }
local toScreenSameRes = { x = 1000, y = 0, w = 1000, h = 800 }
local leftHalfFrame = windowManager.calculateFrame(fromScreen, "left-half")
local translated = windowManager.translateFrame(leftHalfFrame, fromScreen, toScreenSameRes)
assert(translated.x == 1000 and translated.y == 0 and translated.w == 500 and translated.h == 800,
  "translateFrame: expected left-half to land at the same relative spot on an identical same-resolution screen")
passed = passed + 1

local toScreenDifferentRes = { x = 0, y = 800, w = 1200, h = 900 }
local centerFrame = windowManager.calculateFrame(fromScreen, "center")
local translatedDifferentRes = windowManager.translateFrame(centerFrame, fromScreen, toScreenDifferentRes)
assert(translatedDifferentRes.x == 120 and translatedDifferentRes.y == 890
  and translatedDifferentRes.w == 960 and translatedDifferentRes.h == 720,
  "translateFrame: expected proportions preserved when moving to a different-resolution screen")
passed = passed + 1

-- nextScreenIndex: 1-based wraparound in both directions.
assert(windowManager.nextScreenIndex(1, 3, 1) == 2, "nextScreenIndex: expected 1 -> 2 going forward")
passed = passed + 1
assert(windowManager.nextScreenIndex(3, 3, 1) == 1, "nextScreenIndex: expected wraparound 3 -> 1 going forward")
passed = passed + 1
assert(windowManager.nextScreenIndex(1, 3, -1) == 3, "nextScreenIndex: expected wraparound 1 -> 3 going backward")
passed = passed + 1
assert(windowManager.nextScreenIndex(2, 3, -1) == 1, "nextScreenIndex: expected 2 -> 1 going backward")
passed = passed + 1

print(string.format("test_window_manager: %d assertions passed", passed))

-- src/window_manager.lua
-- Pure window-geometry calculations plus a thin Hammerspoon application layer.
-- Connects to: init.lua (bound to hotkeys), tests/test_window_manager.lua
-- Created: 2026-07-05

local M = {}

-- calculateFrame(screenFrame, mode) -> {x, y, w, h}
-- screenFrame: {x, y, w, h} in Hammerspoon screen coordinates.
-- mode: one of the layout keys below.
-- Pure function (no hs.* calls) so it can be unit tested outside Hammerspoon.
function M.calculateFrame(screenFrame, mode)
  local x, y, w, h = screenFrame.x, screenFrame.y, screenFrame.w, screenFrame.h

  local layouts = {
    ["left-half"]         = { x = x,                 y = y,     w = w / 2,       h = h },
    ["right-half"]        = { x = x + w / 2,         y = y,     w = w / 2,       h = h },
    ["top-half"]          = { x = x,                 y = y,     w = w,           h = h / 2 },
    ["bottom-half"]       = { x = x,                 y = y + h / 2, w = w,       h = h / 2 },
    ["left-third"]        = { x = x,                 y = y,     w = w / 3,       h = h },
    ["center-third"]      = { x = x + w / 3,         y = y,     w = w / 3,       h = h },
    ["right-third"]       = { x = x + (2 * w / 3),   y = y,     w = w / 3,       h = h },
    ["left-two-thirds"]   = { x = x,                 y = y,     w = (2 * w) / 3, h = h },
    ["right-two-thirds"]  = { x = x + w / 3,         y = y,     w = (2 * w) / 3, h = h },
    ["maximize"]          = { x = x,                 y = y,     w = w,           h = h },
    ["center"]            = { x = x + w * 0.1,       y = y + h * 0.1, w = w * 0.8, h = h * 0.8 },
  }

  local frame = layouts[mode]
  if not frame then
    error("window_manager.calculateFrame: unknown mode '" .. tostring(mode) .. "'")
  end
  return frame
end

-- apply(win, mode) -> boolean success
-- win: an hs.window object (must respond to :screen() and :setFrame()).
function M.apply(win, mode)
  if not win then
    return false
  end
  local screenFrame = win:screen():frame()
  local frame = M.calculateFrame(screenFrame, mode)
  win:setFrame(frame)
  return true
end

-- translateFrame(frame, fromScreen, toScreen) -> {x, y, w, h}
-- Re-expresses `frame` (given relative to `fromScreen`) as the equivalent
-- frame on `toScreen`, preserving position/size as a proportion of the
-- screen. This keeps a window's relative layout intact when it moves to a
-- monitor with a different resolution or DPI.
function M.translateFrame(frame, fromScreen, toScreen)
  local relX = (frame.x - fromScreen.x) / fromScreen.w
  local relY = (frame.y - fromScreen.y) / fromScreen.h
  local relW = frame.w / fromScreen.w
  local relH = frame.h / fromScreen.h

  return {
    x = toScreen.x + relX * toScreen.w,
    y = toScreen.y + relY * toScreen.h,
    w = relW * toScreen.w,
    h = relH * toScreen.h,
  }
end

-- nextScreenIndex(currentIndex, count, direction) -> integer
-- 1-based wraparound index into a screen list. direction = 1 (next) or -1 (previous).
-- Pure function so the wraparound math can be tested without real hs.screen objects.
function M.nextScreenIndex(currentIndex, count, direction)
  if count <= 0 then
    error("window_manager.nextScreenIndex: count must be positive")
  end
  direction = direction or 1
  local zeroBased = (currentIndex - 1 + direction) % count
  return zeroBased + 1
end

-- moveToScreen(win, direction) -> boolean success
-- Moves the focused window to the next (direction = 1) or previous
-- (direction = -1) screen, preserving its relative position/size.
function M.moveToScreen(win, direction)
  if not win then
    return false
  end

  local screens = hs.screen.allScreens()
  if #screens < 2 then
    return false
  end

  local currentScreen = win:screen()
  local currentIndex
  for i, screen in ipairs(screens) do
    if screen:id() == currentScreen:id() then
      currentIndex = i
      break
    end
  end
  if not currentIndex then
    return false
  end

  local targetIndex = M.nextScreenIndex(currentIndex, #screens, direction)
  local targetScreen = screens[targetIndex]
  local newFrame = M.translateFrame(win:frame(), currentScreen:frame(), targetScreen:frame())
  win:setFrame(newFrame)
  return true
end

return M

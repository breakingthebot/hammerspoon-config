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

return M

--
-- Screen definitions for the default case of two screens above each other (bottom <-> top)
-- "primaryDisplay" and "secondaryDisplay" will be available when this is included
--
local M = {}

--
-- Layout when pressing cmd+shift+9
--
-- Application Name
-- Window Name
-- Display to move to
-- Coordinates table (x,y,w,h),
M.windowLayout = {
  {"Brave Browser", nil, secondaryDisplay, { x = 0, y = 0, w = 0.66, h = 1}, nil, nil},
  {"MacVim", nil, primaryScreen, { x = 0, y = 0, w = 1, h = 1}, nil, nil},
  {"iTerm2", nil, secondaryDisplay, { x = 0.66, y = 0, w = 0.34, h = 1}, nil, nil},
  {"Microsoft Outlook", nil, primaryDisplay, { x = 0, y = 0, w = 1, h = 1}, nil, nil},
  {"Slack", nil, primaryDisplay, { x = 0.5, y = 0, w = 0.5, h = 1}, nil, nil},
  {"Obsidian", nil, primaryDisplay, { x = 0, y = 0, w = 0.66, h = 1}, nil, nil},
  {"Microsoft Teams", nil, primaryDisplay, { x = 0, y = 0, w = 0.5, h = 1}, nil, nil},
}

return M

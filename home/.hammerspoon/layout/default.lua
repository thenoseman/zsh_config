--
-- Screen definitions for the default case of two screens next to each other (left <-> right)
-- "primaryDisplay" and "secondaryDisplay" will be available when this is included
--
--# selene: allow(undefined_variable)
local M = {}

--
-- Layout when pressing cmd+shift+9
--
-- Application Name
-- Window Name
-- Display to move to
-- Coordinates table (x,y,w,h),
M.windowLayout = {
  { "Brave Browser", nil, primaryDisplay, { x = 0, y = 0, w = 0.66, h = 1 }, nil, nil },
  { "MacVim", nil, primaryDisplay, { x = 0, y = 0, w = 0.66, h = 1 }, nil, nil },
  { "iTerm2", nil, primaryDisplay, { x = 0.66, y = 0, w = 0.34, h = 1 }, nil, nil },
  { "Brave Browser", "E-Mail", secondaryDisplay, { x = 0, y = 0, w = 0.66, h = 1 }, nil, nil },
  { "Microsoft Outlook", nil, secondaryDisplay, { x = 0, y = 0, w = 0.66, h = 1 }, nil, nil },
  { "Slack", nil, secondaryDisplay, { x = 0.66, y = 0, w = 0.34, h = 1 }, nil, nil },
  { "Obsidian", nil, secondaryDisplay, { x = 0, y = 0, w = 1, h = 1 }, nil, nil },
  { "Microsoft Teams", nil, secondaryDisplay, { x = 0.66, y = 0, w = 0.34, h = 1 }, nil, nil },
  { "Brave Browser", "DevTools -", secondaryDisplay, { x = 0, y = 0, w = 0.66, h = 1 }, nil, nil },
}

return M

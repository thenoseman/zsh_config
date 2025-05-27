--
-- Company setup (bad HP 524pm displays)
--# selene: allow(undefined_variable)
local M = {}

--
-- Layout when pressing cmd+shift+9
--
-- Application Name
-- Window Name
-- Display to move to
-- Coordinates table (x,y,w,h)
-- nil
-- method to call when matching window title
M.windowLayout = {
  { "Brave Browser", nil, primaryDisplay, { x = 0, y = 0, w = 0.66, h = 1 }, nil, nil },
  { "MacVim", nil, primaryDisplay, { x = 0, y = 0, w = 0.66, h = 1 }, nil, nil },
  { "iTerm2", nil, primaryDisplay, { x = 0.66, y = 0, w = 0.34, h = 1 }, nil, nil },
  { "Microsoft Outlook", nil, secondaryDisplay, { x = 0, y = 0, w = 0.75, h = 1 }, nil, nil },
  { "Slack", nil, secondaryDisplay, { x = 0, y = 0, w = 0.66, h = 1 }, nil, nil },
  { "Obsidian", nil, secondaryDisplay, { x = 0, y = 0, w = 1, h = 1 }, nil, nil },
  { "Microsoft Teams", nil, secondaryDisplay, { x = 0.5, y = 0, w = 0.5, h = 1 }, nil, nil },
  { "Brave Browser", "DevTools -", secondaryDisplay, { x = 0, y = 0, w = 1, h = 1 }, nil, nil },
  { "Microsoft Outlook", "Erinnerung", secondaryDisplay, { x = 0.7, y = 0.8, w = 0.29, h = 0.2 }, nil, string.match },
}

return M

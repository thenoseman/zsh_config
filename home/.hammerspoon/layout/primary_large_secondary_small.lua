--
-- Screen definitions for the default case of two screens above each other (bottom <-> top)
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
  { "Microsoft Outlook", nil, secondaryDisplay, { x = 0, y = 0, w = 1, h = 1 }, nil, nil },
  { "Slack", nil, secondaryDisplay, { x = 0, y = 0, w = 0.66, h = 1 }, nil, nil },
  { "Obsidian", nil, secondaryDisplay, { x = 0, y = 0, w = 1, h = 1 }, nil, nil },
  { "Microsoft Teams", nil, secondaryDisplay, { x = 0.25, y = 0, w = 0.75, h = 1 }, nil, nil },
  { "Brave Browser", "DevTools -", secondaryDisplay, { x = 0, y = 0, w = 1, h = 1 }, nil, nil },
  { "Microsoft Outlook", "Erinnerung", secondaryDisplay, { x = 0.7, y = 0.8, w = 0.29, h = 0.2 }, nil, string.match },
}

return M
--[[
 application = {
    bundleID = "com.microsoft.Outlook",
    name = "Microsoft Outlook",
    pid = 91047,
    title = "Microsoft Outlook",
    visibleWindows = { <userdata 1> -- hs.window: 1 Erinnerung (0x6000002326b8), <userdata 2> -- hs.window: Posteingang • frank.schumacher@telefonica.com (0x600000232db8) }
  },
  window = {
    id = 171,
    role = "AXWindow",
    size_h = 143.0,
    size_w = 400.0,
    subrole = "AXStandardWindow",
    tabCount = 0,
    title = "1 Erinnerung"
  }
}
]]

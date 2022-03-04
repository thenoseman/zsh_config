local status_line_bar = nil
local obsidianBundleID = "md.obsidian"

status_line_bar = hs.menubar.new()
status_line_bar:setTitle("🔘")

status_line_bar:setClickCallback(function()
  hs.application.launchOrFocusByBundleID(obsidianBundleID)
end)

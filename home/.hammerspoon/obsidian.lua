local status_line_bar = nil
local obsidianBundleID = "md.obsidian"


if status_line_bar ~= nil then
  status_line_bar:delete()
end

status_line_bar = hs.menubar.new()
status_line_bar:setTitle("🔘")

status_line_bar:setClickCallback(function()
  hs.application.launchOrFocusByBundleID(obsidianBundleID)
end)

--- === Seal.plugins.apps ===
---
--- A plugin to add launchable apps/scripts, making Seal act as a launch bar
local obj = {}
obj.__index = obj
obj.__name = "seal_apps"
obj.appCache = {}

--- Seal.plugins.apps.appSearchPaths
--- Variable
--- Table containing the paths to search for launchable items
---
--- Notes:
---  * If you change this, you will need to call `spoon.Seal.plugins.apps:restart()` to force Spotlight to search for new items.
obj.appSearchPaths = {
  "/Applications",
  "/System/Applications",
  "~/Applications",
  "/System/Library/PreferencePanes",
  "/Library/PreferencePanes",
  "~/Library/PreferencePanes",
  "/System/Library/CoreServices/Applications",
  "/System/Library/CoreServices/",
}

-- Terms to ignore
-- These apps will not be shown
obj.ignoredApps = {
  "aktien",
}

local function starts_with(str, start)
  return str:sub(1, #start) == start
end

local modifyNameMap = function(info, add)
  for _, item in ipairs(info) do
    icon = nil
    local displayname = item._kMDItemDisplayNameWithExtensions
      or item.kMDItemDisplayName
      or hs.fs.displayName(item.kMDItemPath)
    displayname = displayname:gsub("%.app$", "", 1)
    if string.find(item.kMDItemPath, "%.prefPane$") then
      displayname = displayname .. " Systemeinstellungen"
      if add then
        icon = hs.image.iconForFile(item.kMDItemPath)
      end
    end
    if add then
      bundleID = item.kMDItemCFBundleIdentifier
      if (not icon) and bundleID then
        icon = hs.image.imageFromAppBundle(bundleID)
      end
      obj.appCache[displayname] = {
        path = item.kMDItemPath,
        bundleID = bundleID,
        icon = icon,
      }
    else
      obj.appCache[displayname] = nil
    end
  end
end

local updateNameMap = function(obj, msg, info)
  if info then
    -- all three can occur in either message, so check them all!
    if info.kMDQueryUpdateAddedItems then
      modifyNameMap(info.kMDQueryUpdateAddedItems, true)
    end
    if info.kMDQueryUpdateChangedItems then
      modifyNameMap(info.kMDQueryUpdateChangedItems, true)
    end
    if info.kMDQueryUpdateRemovedItems then
      modifyNameMap(info.kMDQueryUpdateRemovedItems, false)
    end
  else
    -- shouldn't happen for didUpdate or inProgress
    print("~~~ userInfo from SpotLight was empty for " .. msg)
  end
end

--- Seal.plugins.apps:start()
--- Method
--- Starts the Spotlight app searcher
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
---
--- Notes:
---  * This is called automatically when the plugin is loaded
function obj:start()
  obj.spotlight = hs.spotlight
    .new()
    :queryString(
      [[ (kMDItemContentType = "com.apple.application-bundle") || (kMDItemContentType = "com.apple.systempreference.prefpane") ]]
    )
    :callbackMessages("didUpdate", "inProgress")
    :setCallback(updateNameMap)
    :searchScopes(obj.appSearchPaths)
    :start()
end

--- Seal.plugins.apps:stop()
--- Method
--- Stops the Spotlight app searcher
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:stop()
  obj.spotlight:stop()
  obj.spotlight = nil
  obj.appCache = {}
end

--- Seal.plugins.apps:restart()
--- Method
--- Restarts the Spotlight app searcher
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:restart()
  self:stop()
  self:start()
end

hs.application.enableSpotlightForNameSearches(true)
obj:start()

function obj:commands()
  return {
    kill = {
      cmd = "kill",
      fn = obj.choicesKillCommand,
      plugin = obj.__name,
      name = "Kill",
      description = "Kill an application",
    },
    reveal = {
      cmd = "reveal",
      fn = obj.choicesRevealCommand,
      plugin = obj.__name,
      name = "Reveal",
      description = "Reveal an application in the Finder",
    },
  }
end

function obj:bare()
  return self.choicesApps
end

function styled_text(text, highlight)
  return hs.styledtext.new(
    highlight,
    { font = { size = 16 }, color = hs.drawing.color.definedCollections.hammerspoon.black }
  ) .. hs.styledtext.new(string.sub(text, #highlight + 1), { font = { size = 16 } })
end

function generate_choice(name, app, obj, query, mode)
  local choice = {}
  local instances = {}
  if app["bundleID"] then
    instances = hs.application.applicationsForBundleID(app["bundleID"])
  end
  if #instances > 0 then
    choice["text"] = name .. " (Läuft)"
  else
    choice["text"] = name
  end
  choice["subText"] = app["path"]
  if app["icon"] then
    choice["image"] = app["icon"]
  end
  choice["path"] = app["path"]
  choice["uuid"] = obj.__name .. "__" .. (app["bundleID"] or name)
  choice["plugin"] = obj.__name
  choice["type"] = "launchOrFocus"

  -- Highlight entered portion of text
  if mode == "starts_with" then
    choice["text"] = styled_text(choice["text"], query)
  end

  return choice
end

function obj.is_app_ignored(app_name)
  for _, name in pairs(obj.ignoredApps) do
    if string.match(app_name:lower(), name:lower()) then
      return true
    end
  end
  return false
end

function obj.choicesApps(query)
  local choices = {}
  if query == nil or query == "" then
    return choices
  end

  -- First search for apps that start with the term
  for name, app in pairs(obj.appCache) do
    if starts_with(name:lower(), query:lower()) and not obj.is_app_ignored(name) then
      table.insert(choices, generate_choice(name, app, obj, query, "starts_with"))
    end
  end

  -- If nothing was found search for includsion in the name
  if #choices == 0 then
    for name, app in pairs(obj.appCache) do
      if string.match(name:lower(), query:lower()) and not obj.is_app_ignored(name) then
        table.insert(choices, generate_choice(name, app, obj, query, "match"))
      end
    end
  end

  -- Sort choices
  table.sort(choices, function(a, b)
    return a["text"] < b["text"]
  end)
  return choices
end

function obj.choicesKillCommand(query)
  local choices = {}
  if query == nil then
    return choices
  end
  local apps = hs.application.runningApplications()
  for k, app in pairs(apps) do
    local name = app:name()
    if string.match(name:lower(), query:lower()) and app:mainWindow() then
      local choice = {}
      choice["text"] = "Kill " .. name
      choice["subText"] = app:path() .. " PID: " .. app:pid()
      choice["pid"] = app:pid()
      choice["plugin"] = obj.__name
      choice["type"] = "kill"
      choice["image"] = hs.image.imageFromAppBundle(app:bundleID())
      table.insert(choices, choice)
    end
  end
  return choices
end

function obj.choicesRevealCommand(query)
  local choices = {}
  if query == nil then
    return choices
  end
  local apps = obj.choicesApps(query)
  for k, app in pairs(apps) do
    local name = app.text
    if string.match(name:lower(), query:lower()) then
      local choice = {}
      choice["text"] = "Reveal " .. name
      choice["path"] = app.path
      choice["subText"] = app.path
      choice["plugin"] = obj.__name
      choice["type"] = "reveal"
      if app.image then
        choice["image"] = app.image
      end
      table.insert(choices, choice)
    end
  end
  table.sort(choices, function(a, b)
    return a["text"] < b["text"]
  end)
  return choices
end

function obj.completionCallback(rowInfo)
  if rowInfo["type"] == "launchOrFocus" then
    if string.find(rowInfo["path"], "%.applescript$") or string.find(rowInfo["path"], "%.scpt$") then
      hs.task.new("/usr/bin/osascript", nil, { rowInfo["path"] }):start()
    else
      hs.task.new("/usr/bin/open", nil, { rowInfo["path"] }):start()
    end
  elseif rowInfo["type"] == "kill" then
    hs.application.get(rowInfo["pid"]):kill()
  elseif rowInfo["type"] == "reveal" then
    hs.osascript.applescript(string.format([[tell application "Finder" to reveal (POSIX file "%s")]], rowInfo["path"]))
    hs.application.launchOrFocus("Finder")
  end
end

return obj

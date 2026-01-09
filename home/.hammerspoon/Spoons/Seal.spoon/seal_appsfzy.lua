--- A plugin to add launchable apps/scripts, making Seal act as a launch bar
--- Uses fzy.lua for fuzzy and fast searches
local fzy = require("fzy")
local obj = {}
obj.__index = obj
obj.__name = "seal_appsfzy"
obj.appCache = {}
obj.appNameCache = {}

--- Where should spotlight search for stuff?
obj.appSearchPaths = {
  "/Applications",
  "/Library/PreferencePanes",
  "/System/Applications",
  "/System/Library/CoreServices/",
  "/System/Library/CoreServices/Applications",
  "/System/Library/PreferencePanes",
  "~/Applications",
  "~/Library/PreferencePanes",
}

-- Terms to ignore
-- These apps will not be shown
-- use lowercase
obj.ignoredApps = {
  "aktien",
}

-- Build cache of apps to query later
local modifyNameMap = function(info, add)
  for _, item in ipairs(info) do
    local icon = nil
    local displayname = item.kMDItemDisplayName or item._kMDItemDisplayNameWithExtensions

    if displayname == nil and item.kMDItemPath then
      displayname = hs.fs.displayName(item.kMDItemPath)
    end

    if displayname then
      displayname = displayname:gsub("%.app$", "", 1)
    end

    -- Is a System Preference? ("Systemeinstellung" in german)
    if string.find(item.kMDItemPath, "%.prefPane$") then
      -- "Systemeinstellung" instead of prefPane please
      displayname = displayname:gsub("%.prefPane$", "", 1)
      displayname = displayname .. " Systemeinstellungen"
      if add then
        icon = hs.image.iconForFile(item.kMDItemPath)
      end
    end

    if add then
      local bundleID = item.kMDItemCFBundleIdentifier
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

  -- Generate fresh list of appnames for fzy to search thru
  obj.appNameCache = {}
  for appName in pairs(obj.appCache) do
    -- Do not add ignored apps
    if not obj.is_app_ignored(appName) then
      obj.appNameCache[#obj.appNameCache + 1] = appName
    end
  end
end

-- callback that calls the update to the appcache
local updateNameMap = function(_obj, msg, info)
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
    -- shouldn't happen for didUpdate
    print("userInfo from SpotLight was empty for " .. msg)
  end
end

-- Highlight positions in a text using hammerpsoon styledtext
local function highlight(text, letterPositions)
  -- Generate an index for lookup later
  local letterLookup = {}
  for _, i in ipairs(letterPositions) do
    letterLookup[i] = true
  end

  local result = hs.styledtext.new("", { font = { size = 16 } })

  -- Loop thru every letter
  for i = 1, #text do
    local char = text:sub(i, i)

    -- Strange characters in string should be ignored (ASCII Extendex decimal values)
    if string.byte(char) < 155 then
      -- If there is a match from fzy ...
      if letterLookup[i] then
        result = result
          .. hs.styledtext.new(
            char,
            { font = { size = 16 }, color = hs.drawing.color.definedCollections.hammerspoon.black }
          )
      else
        -- No match
        result = result .. hs.styledtext.new(char, { font = { size = 16 } })
      end
    end
  end

  return result
end

--
-- Create the "choice" structure for one app
--
local function generate_choice(name, app, letterPositions)
  local choice = {}
  --choice["text"] = highlight(name, letterPositions)
  choice["text"] = name
  choice["subText"] = app["path"]
  choice["plugin"] = obj.__name -- Important! Otherwise seal will not execute the action on [ENTER]
  choice["path"] = app["path"]
  choice["uuid"] = "__" .. (app["bundleID"] or name)
  if app["icon"] then
    choice["image"] = app["icon"]
  end

  return choice
end

--- This is called automatically when the plugin is loaded
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

--- Stops the Spotlight app searcher
function obj:stop()
  obj.spotlight:stop()
  obj.spotlight = nil
  obj.appCache = {}
end

--- Restarts the Spotlight app searcher
function obj:restart()
  self:stop()
  self:start()
end

function obj:bare()
  return self.choicesApps
end

-- should an app be ignored?
function obj.is_app_ignored(app_name)
  for _, name in pairs(obj.ignoredApps) do
    if string.match(app_name:lower(), name:lower()) then
      return true
    end
  end
  return false
end

-- Generate the structure a hammerspoon chooser needs
function obj.choicesApps(query)
  local choices = {}
  if query == nil or query == "" then
    return {}
  end

  -- Search
  -- {
  --   {2, {1, 5,  9}, 2.63},
  --    ^  ^           ^-- Score (higher is better)
  --    |  \-------------- index of letters found (starts at 1)
  --    \----------------- index in hackstay
  -- }
  local matches = fzy.filter(query, obj.appNameCache)

  -- Sort by score descending
  table.sort(matches, function(a, b)
    return (a[3] > b[3])
  end)

  -- Create the table with appname => app mapping
  local appsFound = hs.fnutils.imap(matches, function(match)
    return {
      name = obj.appNameCache[match[1]],
      letterPositions = match[2],
    }
  end)

  -- Generate choices structure
  for _, app in pairs(appsFound) do
    if obj.appCache[app.name] then
      table.insert(choices, generate_choice(app.name, obj.appCache[app.name], app.letterPositions))
    end
  end

  return choices
end

-- Execute open action
function obj.completionCallback(rowInfo)
  hs.task.new("/usr/bin/open", nil, { rowInfo["path"] }):start()
end

hs.application.enableSpotlightForNameSearches(true)
obj:start()

return obj

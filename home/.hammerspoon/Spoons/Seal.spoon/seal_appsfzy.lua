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

-- German translations for System Preference / System Settings panes.
-- On modern macOS the real .prefPane bundles are empty legacy stubs (the
-- actual UI lives inside System Settings.app's extensions), so Spotlight's
-- kMDItemDisplayName just falls back to the English bundle filename and
-- there is no reliable, queryable source for the real localized pane name.
--
-- The actual translations live in prefpane_translations.conf (human-edited
-- source of truth) and are compiled into prefpane_translations.lua by
-- prefpane_translations.sh. Run that script after editing
-- the .conf file. Keyed by the bundle filename (without the .prefPane
-- extension), which is stable across macOS versions/locales, unlike the
-- display name.
obj.prefPaneTranslations = dofile(hs.spoons.scriptPath() .. "prefpane_translations.lua")

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
    if item.kMDItemPath and string.find(item.kMDItemPath, "%.prefPane$") then
      -- Use the stable bundle filename (not the display name) to look up
      -- the German translation, since kMDItemDisplayName is unreliable/
      -- English-only for these on modern macOS (see prefPaneTranslations).
      local bundleName = item.kMDItemPath:match("([^/]+)%.prefPane$")
      local translated = bundleName and obj.prefPaneTranslations[bundleName]

      -- "Systemeinstellung" instead of prefPane please
      displayname = displayname:gsub("%.prefPane$", "", 1)
      displayname = (translated or displayname) .. " Systemeinstellungen"
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

--
-- Create the "choice" structure for one app
--
local function generate_choice(name, app)
  local choice = {}
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
function obj.start()
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
function obj.stop()
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
      table.insert(choices, generate_choice(app.name, obj.appCache[app.name]))
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

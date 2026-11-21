--- A plugin to add launchable apps/scripts, making Seal act as a launch bar
--- Uses fzy.lua for fuzzy and fast searches
local fzy = require("fzy")
local utils = dofile(hs.spoons.scriptPath() .. "utils.lua")
local obj = {}
obj.__index = obj
obj.__name = "seal_appsfzy"
obj.appCache = {}
obj.appNameCache = {}
obj.settingsCache = {}

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
obj.prefPaneTranslations = dofile(hs.spoons.scriptPath() .. "prefpane_translations.lua")

local preferencesIcon = hs.image.iconForFile("/System/Applications/System Settings.app")

-- Modern System Settings panes are extensions, not Spotlight-indexed .prefPanes.
obj.settingsExtensionPaths = {
  "/System/Library/ExtensionKit/Extensions",
  "/System/Applications/System Settings.app/Contents/PlugIns",
}

-- Some extensions share legacy aliases, or omit the legacy filename entirely.
obj.settingsPaneNames = {
  ["com.apple.Spotlight-Settings.extension"] = "Spotlight",
  ["com.apple.Siri-Settings.extension"] = "Siri",
  ["com.apple.wifi-settings-extension"] = "WiFi",
  ["com.apple.Battery-Settings.extension"] = "Battery",
}

local function rebuildNameCache()
  obj.appNameCache = {}
  local names = {}
  for _, cache in ipairs({ obj.appCache, obj.settingsCache }) do
    for name in pairs(cache) do
      if not names[name] and not obj.is_app_ignored(name) then
        names[name] = true
        obj.appNameCache[#obj.appNameCache + 1] = name
      end
    end
  end
end

local function cacheSettings()
  obj.settingsCache = {}

  local function addPane(bundleName, displayname, path, bundleID, url)
    local name = (obj.prefPaneTranslations[bundleName] or displayname or bundleName) .. " Systemeinstellungen"
    obj.settingsCache[name] = {
      path = path,
      bundleID = bundleID,
      icon = preferencesIcon,
      url = url,
    }
  end

  local function scan(path, suffix, callback)
    path = path:gsub("^~/", os.getenv("HOME") .. "/")
    if hs.fs.attributes(path, "mode") ~= "directory" then
      return
    end
    for filename in hs.fs.dir(path) do
      if filename:sub(-#suffix) == suffix then
        local bundlePath = path .. "/" .. filename
        local info = hs.plist.read(bundlePath .. "/Contents/Info.plist")
        if info then
          callback(filename, bundlePath, info)
        end
      end
    end
  end

  -- Keep real legacy/third-party bundles available even when Spotlight misses them.
  -- Empty system stubs have no Info.plist and must not become launch targets.
  for _, path in ipairs(obj.appSearchPaths) do
    if path:match("/PreferencePanes/?$") then
      scan(path, ".prefPane", function(filename, bundlePath, info)
        local bundleName = filename:gsub("%.prefPane$", "")
        local displayname = hs.fs.displayName(bundlePath) or bundleName
        addPane(bundleName, displayname:gsub("%.prefPane$", ""), bundlePath, info.CFBundleIdentifier)
      end)
    end
  end

  -- Extension metadata supplies both the translation key and a supported deep link.
  -- Prefer these entries over legacy bundles with the same translated name.
  for _, path in ipairs(obj.settingsExtensionPaths) do
    scan(path, ".appex", function(_filename, bundlePath, info)
      local attributes = info.EXAppExtensionAttributes or {}
      local settings = attributes.SettingsExtensionAttributes or {}
      local legacyName = settings.legacyPrefPaneBundleName
      if type(legacyName) == "table" then
        legacyName = legacyName[1]
      end
      local bundleName = obj.settingsPaneNames[info.CFBundleIdentifier]
        or (type(legacyName) == "string" and legacyName:gsub("%.prefPane$", ""))
      if
        attributes.EXExtensionPointIdentifier == "com.apple.Settings.extension.ui"
        and settings.allowsXAppleSystemPreferencesURLScheme == true
        and bundleName
        and info.CFBundleIdentifier
      then
        addPane(
          bundleName,
          info.CFBundleDisplayName or info.CFBundleName,
          bundlePath,
          info.CFBundleIdentifier,
          "x-apple.systempreferences:" .. info.CFBundleIdentifier
        )
      end
    end)
  end

  rebuildNameCache()
end

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
      -- Use the stable bundle filename (not the display name) to look up the German translation,
      local bundleName = item.kMDItemPath:match("([^/]+)%.prefPane$")
      local translated = bundleName and obj.prefPaneTranslations[bundleName]

      -- "Systemeinstellung" instead of prefPane please
      displayname = displayname:gsub("%.prefPane$", "", 1)
      displayname = (translated or displayname) .. " Systemeinstellungen"
      if add then
        icon = preferencesIcon
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

  -- Generate fresh list of appnames for fzy to search thru, retaining settings.
  rebuildNameCache()
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
local function generate_choice(name, app, query)
  local choice = {}
  choice["text"] = utils.highlightMatches(name, query)
  choice["subText"] = app["path"]
  choice["plugin"] = obj.__name -- Important! Otherwise seal will not execute the action on [ENTER]
  choice["path"] = app["path"]
  choice["url"] = app["url"]
  choice["uuid"] = "__" .. (app["bundleID"] or name)
  if app["icon"] then
    choice["image"] = app["icon"]
  end

  return choice
end

--- This is called automatically when the plugin is loaded
function obj.start()
  cacheSettings()
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
  obj.settingsCache = {}
  obj.appNameCache = {}
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
    local entry = obj.settingsCache[app.name] or obj.appCache[app.name]
    if entry then
      table.insert(choices, generate_choice(app.name, entry, query))
    end
  end

  return choices
end

-- Execute open action
function obj.completionCallback(rowInfo)
  hs.task.new("/usr/bin/open", nil, { rowInfo["url"] or rowInfo["path"] }):start()
end

hs.application.enableSpotlightForNameSearches(true)
obj:start()

return obj

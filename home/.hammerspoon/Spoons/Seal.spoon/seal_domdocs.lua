--- === Seal.plugins.domdocs ===
--- Open DOM Documentation from Seal on devdocs.io
local log = hs.logger.new("[domdocs]", "debug")

local fzy = require("fzy")

local obj = {}
obj.__index = obj
obj.__name = "nodedocs"
obj.cache = {}
obj.icon = hs.image.imageFromPath(hs.spoons.scriptPath() .. "/dom/dom-logo.png")

--- Variable
--- String that the query must start with to be recognized
obj.trigger = "dom "

function script_path()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end

local indexFile = script_path() .. "/dom/dom-index.txt"

local file_info_last_modified = hs.fs.attributes(indexFile, "modification")
if file_info_last_modified == nil then
  local t = "Generate the DOM API index using \n'$HOME/.hammerspoon/Spoons/Seal.spoon/dom/generate.sh"
  log.i(t)
  hs.alert.show(t, {}, hs.screen.mainScreen(), 10)
else
  log.i("Using pre-existing '" .. indexFile)
end

local function starts_with(str, start)
  return str:sub(1, #start) == start
end

function fuzzyMatch(query, hackstay)
  local matches = fzy.filter(query, hackstay)

  -- Sort by score descending
  table.sort(matches, function(a, b)
    return (a[3] > b[3])
  end)
  --- Take first 10 matches
  matches = table.move(matches, 1, 10, 1, {})

  -- Convert indices to the cache entries
  return hs.fnutils.imap(matches, function(match)
    return hackstay[match[1]]
  end)
end

function obj:stop()
  obj.cache = nil
end

function obj:bare()
  return self.choices
end

function obj.choices(query)
  local choices = {}
  if query == nil or query == "" or not starts_with(query, obj.trigger) then
    return choices
  end

  -- Strip trigger
  query = query:gsub("^" .. obj.trigger, "")

  obj.cache = {}
  for line in io.lines(indexFile) do
    obj.cache[#obj.cache + 1] = line
  end

  for _, definition in pairs(fuzzyMatch(query, obj.cache)) do
    local parts = hs.fnutils.split(definition, "|")
    local choice = {}
    choice["text"] = parts[1]
    choice["subText"] = parts[3]
    choice["url"] = parts[2]
    choice["uuid"] = obj.__name .. "__" .. parts[2]
    choice["image"] = obj.icon
    choice["plugin"] = obj.__name
    table.insert(choices, choice)
  end
  return choices
end

function obj.completionCallback(rowInfo)
  hs.execute(string.format("/usr/bin/open '%s'", "https://devdocs.io/dom/" .. rowInfo["url"]))
end

return obj

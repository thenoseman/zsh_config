--- === Seal.plugins.domdocs ===
--- Open kubernetes Documentation from Seal
local log = hs.logger.new("[kubernetesdocs]", "debug")

local utils = dofile(hs.spoons.scriptPath() .. "utils.lua")

local obj = {}
obj.__index = obj
obj.__name = "kubernetesdocs"
obj.cache = {}
obj.icon = hs.image.imageFromPath(hs.spoons.scriptPath() .. "/kubernetes/logo.png")
obj.description = "Search for resources in the kubernetes documentation"

--- Variable
--- String that the query must start with to be recognized
obj.trigger = "k8s "

local indexFile = hs.spoons.scriptPath() .. "/kubernetes/index.txt"

local file_info_last_modified = hs.fs.attributes(indexFile, "modification")
if file_info_last_modified == nil then
  local t =
    "Generate the kubernetes API index using \ncd ~/.hammerspoon/Spoons/Seal.spoon/kubernetes && npm ci && node generate.mjs"
  log.i(t)
  hs.alert.show(t, {}, hs.screen.mainScreen(), 10)
end

function obj:stop()
  obj.cache = nil
end

function obj:bare()
  return self.choices
end

function obj.choices(query)
  local choices = {}
  if query == nil or query == "" or not utils.starts_with(query, obj.trigger) then
    return choices
  end

  -- Strip trigger
  query = query:gsub("^" .. obj.trigger, "")

  obj.cache = {}
  for line in io.lines(indexFile) do
    obj.cache[#obj.cache + 1] = line
  end

  for _, definition in pairs(utils.fuzzyMatch(query, obj.cache)) do
    local parts = hs.fnutils.split(definition, "|")
    local choice = {}
    choice["text"] = utils.highlightMatches(parts[1], query)
    choice["subText"] = parts[3]
    choice["url"] = parts[2]
    choice["uuid"] = obj.__name .. "__" .. parts[2]
    choice["image"] = obj.icon
    choice["plugin"] = obj.__name
    table.insert(choices, choice)
  end
  return choices
end

-- https://v1-34.docs.kubernetes.io/docs/reference/kubernetes-api/_print/#pg-b6a8b05b60848f88f4446e5becc55301
function obj.completionCallback(rowInfo)
  hs.execute(string.format("/usr/bin/open '%s'", rowInfo["url"]))
end

return obj

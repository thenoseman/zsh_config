--
-- Lookup AWS JS SDK docs
--
-- Enter "aws <your query>" in the Seal chooser
--
-- To make this work you must run ./aws-js-sdk/create_aws_sdk_index.mjs at least once!
--
--
local log = hs.logger.new("[awsjs]", "debug")
local fzy = require("fzy")

local obj = {}
obj.__index = obj
obj.__name = "awsjsdocs"
obj.packageMapCache = {}
obj.methodCache = {}
obj.icon = hs.image.imageFromPath(hs.spoons.scriptPath() .. "/aws-js-sdk/logo.png")

--- Seal.plugins.awssdkdocs.trigger
--- Variable
--- String that the query must start with to be recognized
obj.trigger = "aws "
obj.trigger_min_length = 4

function script_path()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
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

  -- Convert indices to the nameCache entries
  return hs.fnutils.imap(matches, function(match)
    return hackstay[match[1]]
  end)
end

--- Fill caches (index => package name)
local packageMapFile = script_path() .. "/aws-js-sdk/aws-sdk-package-map.json"
log.i("Looking for " .. packageMapFile)

local file_info_last_modified = hs.fs.attributes(packageMapFile, "modification")
if file_info_last_modified == nil then
  local t = "Download the aws sdk docs using \n'node $HOME/.hammerspoon/Spoons/Seal.spoon/aws-js-sdk/generate.mjs'"
  log.i(t)
  hs.alert.show(t, {}, hs.screen.mainScreen(), 10)
else
  log.i("Using pre-existing '$HOME/.hammerspoon/Spoons/Seal.spoon/aws-js-sdk/aws-sdk-package-map.json")
end
obj.packageMapCache = hs.json.read(script_path() .. "/aws-js-sdk/aws-sdk-package-map.json")

-- When Seal i
function obj:stop()
  obj.packageMap = nil
  obj.methodCache = nil
end

function obj:commands()
  return {}
end

function obj:bare()
  return self.choices
end

function obj.choices(query)
  local choices = {}

  if query == nil or query == "" or not starts_with(query, obj.trigger) then
    return choices
  end

  if #query < (#obj.trigger + obj.trigger_min_length) then
    return {
      {
        ["text"] = "AWS SDK search: Need at least " .. obj.trigger_min_length .. " characters",
        ["image"] = obj.icon,
      },
    }
  end

  -- Strip trigger
  query = query:gsub("^" .. obj.trigger, "")

  if #obj.methodCache == 0 then
    for line in io.lines(script_path() .. "/aws-js-sdk/aws-sdk-js.txt") do
      obj.methodCache[#obj.methodCache + 1] = line
    end
  end

  for _, definition in pairs(fuzzyMatch(query, obj.methodCache)) do
    local parts = hs.fnutils.split(definition, "|")
    local choice = {}
    choice["text"] = parts[1]
    choice["subText"] = "package: " .. obj.packageMapCache[parts[3]]
    choice["package"] = obj.packageMapCache[parts[3]]
    choice["type"] = parts[2]
    choice["uuid"] = obj.__name .. "__" .. parts[1]
    choice["image"] = obj.icon
    choice["plugin"] = obj.__name
    table.insert(choices, choice)
  end

  return choices
end

-- https://docs.aws.amazon.com/AWSJavaScriptSDK/v3/latest/Package/-aws-sdk-client-sesv2/Interface/SendEmailCommandInput/
function obj.completionCallback(choice)
  local url = "https://docs.aws.amazon.com/AWSJavaScriptSDK/v3/latest/Package/-"
    .. choice["package"]
    .. "/"
    .. choice["type"]
    .. "/"
    .. choice["text"]
    .. "/"
  log.i("Opening " .. url)
  hs.execute(string.format("/usr/bin/open '%s'", url))
  obj.stop()
end

return obj

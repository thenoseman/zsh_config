--
-- Lookup AWS JS SDK docs
--
-- Enter "aws <your query>" in the Seal chooser
--
-- To make this work you must run ./aws-js-sdk/create_aws_sdk_index.mjs at least once!
--
--
local log = hs.logger.new("[awsjs]", "debug")

local utils = dofile(hs.spoons.scriptPath() .. "utils.lua")

local obj = {}
obj.__index = obj
obj.__name = "awsjsdocs"
obj.packageMapCache = {}
obj.methodCache = {}
obj.icon = hs.image.imageFromPath(hs.spoons.scriptPath() .. "/aws-js-sdk/logo.png")
obj.description = "Search for object in the AWS SDK for Javascript"

--- Seal.plugins.awssdkdocs.trigger
--- Variable
--- String that the query must start with to be recognized
obj.trigger = "aws "
obj.trigger_min_length = 4

local packageMapFile = hs.spoons.scriptPath() .. "/aws-js-sdk/aws-sdk-package-map.json"

local file_info_last_modified = hs.fs.attributes(packageMapFile, "modification")
if file_info_last_modified == nil then
  local t = "Download the aws sdk docs using \n'node $HOME/.hammerspoon/Spoons/Seal.spoon/aws-js-sdk/generate.mjs'"
  log.i(t)
  hs.alert.show(t, {}, hs.screen.mainScreen(), 10)
end
obj.packageMapCache = hs.json.read(hs.spoons.scriptPath() .. "/aws-js-sdk/aws-sdk-package-map.json")

function obj:stop()
  obj.packageMap = nil
  obj.methodCache = {}
end

function obj:bare()
  return self.choices
end

function obj.choices(query)
  local choices = {}

  if query == nil or query == "" or not utils.starts_with(query, obj.trigger) then
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
    for line in io.lines(hs.spoons.scriptPath() .. "/aws-js-sdk/aws-sdk-js.txt") do
      obj.methodCache[#obj.methodCache + 1] = line
    end
  end

  for _, definition in pairs(utils.fuzzyMatch(query, obj.methodCache)) do
    local parts = hs.fnutils.split(definition, "|")
    local choice = {}
    choice["text"] = utils.highlightMatches(parts[2], query)
    choice["methodName"] = parts[2]
    choice["subText"] = "package: " .. obj.packageMapCache[parts[4]]
    choice["package"] = obj.packageMapCache[parts[4]]
    choice["type"] = parts[3]
    choice["uuid"] = obj.__name .. "__" .. parts[2]
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
    .. choice["methodName"]
    .. "/"
  log.i("Opening " .. url)
  hs.execute(string.format("/usr/bin/open '%s'", url))
  obj.stop()
end

return obj

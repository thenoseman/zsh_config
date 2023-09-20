--
-- Lookup terraform AWS provider elements (resource + data)
--
-- Enter "aws_ <your query>" in the Seal chooser
--
-- To make this work you must run ./aws-terraform/generate-tf-aws-provider-index.sh at least once!
--
--
local log = hs.logger.new("[awstf]", "debug")
local fzy = require("fzy")

local obj = {}
obj.__index = obj
obj.__name = "awstfdocs"
obj.cache = {}
obj.icon = hs.image.imageFromPath(hs.spoons.scriptPath() .. "/aws-terraform/terraform-logo.png")

local icons = {
  ["resources"] = hs.image.imageFromPath(hs.spoons.scriptPath() .. "/aws-terraform/terraform-resource.png"),
  ["data-sources"] = hs.image.imageFromPath(hs.spoons.scriptPath() .. "/aws-terraform/terraform-data.png"),
}

--- Seal.plugins.awssdkdocs.trigger
--- Variable
--- String that the query must start with to be recognized
obj.trigger = "aws_"
obj.trigger_min_length = 2

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

local indexFile = script_path() .. "/aws-terraform/terraform-provider-aws-index.txt"
log.i("Looking for " .. indexFile)

local file_info_last_modified = hs.fs.attributes(indexFile, "modification")
if file_info_last_modified == nil then
  local t =
    "Generate the terraform AWS provider index using \n'node $HOME/.hammerspoon/Spoons/Seal.spoon/aws-terraform/generate-tf-aws-provider-index.sh"
  log.i(t)
  hs.alert.show(t, {}, hs.screen.mainScreen(), 10)
else
  log.i("Using pre-existing '" .. indexFile)
end

function fill_cache()
  obj.cache = {}
  for line in io.lines(indexFile) do
    obj.cache[#obj.cache + 1] = line
  end
end

function obj:stop()
  obj.cache = nil
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
        ["text"] = "Need at least " .. obj.trigger_min_length .. " characters",
        ["image"] = obj.icon,
      },
    }
  end

  -- Strip trigger
  query = query:gsub("^" .. obj.trigger, "")
  fill_cache()

  for _, definition in pairs(fuzzyMatch(query, obj.cache)) do
    -- accessanalyzer_analyzer|IAM Access Analyzer|resource|Manages an Access Analyzer Analyzer
    local parts = hs.fnutils.split(definition, "|")

    local choice = {}
    choice["text"] = "aws_" .. parts[1]
    choice["subText"] = parts[2] .. ": " .. parts[4]
    choice["type"] = parts[3]
    choice["name"] = parts[1]
    choice["uuid"] = obj.__name .. "__" .. parts[1]
    choice["image"] = icons[parts[3]]
    choice["plugin"] = obj.__name
    table.insert(choices, choice)
  end

  return choices
end

-- https://docs.aws.amazon.com/AWSJavaScriptSDK/v3/latest/Package/-aws-sdk-client-sesv2/Interface/SendEmailCommandInput/
function obj.completionCallback(choice)
  local url = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/"
    .. choice["type"]
    .. "/"
    .. choice["name"]
  log.i("Opening " .. url)
  hs.execute(string.format("/usr/bin/open '%s'", url))
  obj.stop()
end

return obj

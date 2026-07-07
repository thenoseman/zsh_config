--
-- Lookup terraform AWS provider elements (resource + data)
--
-- Enter "aws_ <your query>" in the Seal chooser
--
-- To make this work you must run ./aws-terraform/generate-tf-aws-provider-index.sh at least once!
--
--
local log = hs.logger.new("[awstf]", "debug")

local utils = dofile(hs.spoons.scriptPath() .. "utils.lua")

local obj = {}
obj.__index = obj
obj.__name = "awstfdocs"
obj.cache = {}
obj.icon = hs.image.imageFromPath(hs.spoons.scriptPath() .. "/aws-terraform/terraform-logo.png")
obj.description = "Search for resources, functions and data elements in the terraform docs"

local icons = {
  ["resources"]    = hs.image.imageFromPath(hs.spoons.scriptPath() .. "/aws-terraform/terraform-resource.png"),
  ["data-sources"] = hs.image.imageFromPath(hs.spoons.scriptPath() .. "/aws-terraform/terraform-data.png"),
  ["function"]     = hs.image.imageFromPath(hs.spoons.scriptPath() .. "/aws-terraform/terraform-function.png"),
}

--- Seal.plugins.awssdkdocs.trigger
--- Variable
--- String that the query must start with to be recognized
obj.trigger = "aws_"
obj.trigger_min_length = 2

local indexFile = hs.spoons.scriptPath() .. "/aws-terraform/terraform-provider-aws-index.txt"

local file_info_last_modified = hs.fs.attributes(indexFile, "modification")
if file_info_last_modified == nil then
  local t =
    "Generate the terraform AWS provider index using \n'$HOME/.hammerspoon/Spoons/Seal.spoon/aws-terraform/generate.sh"
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

  obj.cache = {}
  for line in io.lines(indexFile) do
    obj.cache[#obj.cache + 1] = line
  end

  for _, definition in pairs(utils.fuzzyMatch(query, obj.cache)) do
    -- accessanalyzer_analyzer|IAM Access Analyzer|resource|Manages an Access Analyzer Analyzer
    local parts = hs.fnutils.split(definition, "|")

    local choice = {}
    choice["text"] = utils.highlightMatches("aws_" .. parts[1], query)
    choice["subText"] = parts[2] .. ": " .. parts[4]
    choice["type"] = parts[3]
    choice["name"] = parts[1]
    choice["uuid"] = obj.__name .. "__" .. parts[1]
    choice["image"] = icons[parts[3]]
    choice["plugin"] = obj.__name

    if choice["type"] == "function" then
      if choice["name"] == "index" then
        choice["name"] = "index_function"
      end
      choice["text"] = utils.highlightMatches(parts[1] .. " (function)", query)
    end
    table.insert(choices, choice)
  end

  return choices
end

function obj.completionCallback(choice)
  local url = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/"
    .. choice["type"]
    .. "/"
    .. choice["name"]
  if choice["type"] == "function" then
    url = "https://developer.hashicorp.com/terraform/language/functions/" .. choice["name"]
  end

  hs.execute(string.format("/usr/bin/open '%s'", url))
  obj.stop()
end

return obj

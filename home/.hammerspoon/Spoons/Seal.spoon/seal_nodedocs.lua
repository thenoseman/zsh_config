--- === Seal.plugins.nodedocs ===
--- Open Node JS Documentation from Seal on devdocs.io
---
---
local log = hs.logger.new("[nodedocs]", "debug")

local obj = {}
obj.__index = obj
obj.__name = "nodedocs"
obj.cache = {}
obj.icon = hs.image.imageFromPath(hs.spoons.scriptPath() .. "/node-js-logo.png")

--- Seal.plugins.nodedocs.nodejs_version
--- Variable
--- Specify the node js version that should be looked up (18, 20), defaults to "latest"
obj.nodejs_version = nil

--- Seal.plugins.nodedocs.download_if_older_than_sec
--- Variable
--- Seconds to wait until the node docs are downlaoded again
obj.download_if_older_than_sec = 86400

local docs_target_file = hs.fs.temporaryDirectory() .. "/node-docs.json"

function download_docs(target_file)
  --- Download node js documentation json
  local sourceUrl = "https://devdocs.io/docs/node/index.json"
  local response_code, response_body = hs.http.get(sourceUrl)

  if response_code == 200 then
    local json = hs.json.decode(response_body)["entries"]
    log.i("Writing node JSON file to " .. target_file)
    hs.json.write(json, target_file, false, true)
  end
end

--- Download JSON file if necessary
local file_info_last_modified = hs.fs.attributes(docs_target_file, "modification")
if
  file_info_last_modified == nil
  or file_info_last_modified < (os.time(os.date("!*t")) - obj.download_if_older_than_sec)
then
  download_docs(docs_target_file)
end
obj.cache = hs.json.read(docs_target_file)

function obj:commands()
  return {}
end

function obj:bare()
  return self.choices
end

function obj.choices(query)
  local choices = {}
  if query == nil or query == "" then
    return choices
  end

  for _, definition in pairs(obj.cache) do
    if string.match(definition["name"]:lower(), query:lower()) then
      local choice = {}
      choice["text"] = definition["name"]
      choice["subText"] = definition["type"]
      choice["url"] = definition["path"]
      choice["uuid"] = obj.__name .. "__" .. definition["path"]
      choice["image"] = obj.icon
      choice["plugin"] = obj.__name
      table.insert(choices, choice)
    end
  end
  return choices
end

function obj.completionCallback(rowInfo)
  hs.execute(string.format("/usr/bin/open '%s'", "https://devdocs.io/node/" .. rowInfo["url"]))
end

return obj

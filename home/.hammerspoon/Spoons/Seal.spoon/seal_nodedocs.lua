--- === Seal.plugins.nodedocs ===
--- Open Node JS Documentation from Seal on devdocs.io
local log = hs.logger.new("[nodedocs]", "debug")

local fzy = require("fzy")

local obj = {}
obj.__index = obj
obj.__name = "nodedocs"
obj.nameCache = {}
obj.icon = hs.image.imageFromPath(hs.spoons.scriptPath() .. "/node-js-logo.png")

--- Seal.plugins.nodedocs.download_url
--- Variable
--- Basis for functionality (URL on devdocs)
obj.download_url = "https://devdocs.io/docs/node/index.json"

--- Seal.plugins.nodedocs.download_if_older_than_sec
--- Variable
--- Seconds to wait until the node docs are downlaoded again
obj.download_if_older_than_sec = 86400

--- Seal.plugins.nodedocs.trigger
--- Variable
--- String that the query must start with to be recognized
obj.trigger = "n "

local docs_target_file = hs.fs.temporaryDirectory() .. "/node-docs.json"

function download_docs(target_file)
  --- Download node js documentation json
  local response_code, response_body = hs.http.get(obj.download_url)

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

--- Fill caches
--- Concatenate parts since we can only search over a string not a table
obj.nameCache = hs.fnutils.imap(hs.json.read(docs_target_file), function(entry)
  return entry["name"] .. "|" .. entry["path"] .. "|" .. entry["type"]
end)

local function starts_with(str, start)
  return str:sub(1, #start) == start
end

function fuzzyMatch(query)
  local matches = fzy.filter(query, obj.nameCache)
  -- Sort by score descending
  table.sort(matches, function(a, b)
    return (a[3] > b[3])
  end)
  --- Take first 10 matches
  matches = table.move(matches, 1, 10, 1, {})

  -- Convert indices to the naemCache entries
  return hs.fnutils.imap(matches, function(match)
    return obj.nameCache[match[1]]
  end)
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

  -- Strip trigger
  query = query:gsub("^" .. obj.trigger, "")

  for _, definition in pairs(fuzzyMatch(query)) do
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
  hs.execute(string.format("/usr/bin/open '%s'", "https://devdocs.io/node/" .. rowInfo["url"]))
end

return obj

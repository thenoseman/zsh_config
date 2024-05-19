--
-- Removes junk files from external volumes
--
local logger = require("hs.logger").new("[junk]", "debug")
local watchers = {}

-- Which files to automatically remove after creation:
local junkFileNames = { ".DS_Store" }

function junkWatcher(paths, pathFlags)
  hs.fnutils.each(paths, function(path)
    -- Does it match and of the junkFileNames?
    local endsWithJunkFileName = hs.fnutils.some(junkFileNames, function(junkFileName)
      return string.match(path, junkFileName .. "$")
    end)

    if endsWithJunkFileName then
      local index = hs.fnutils.indexOf(paths, path)
      if pathFlags[index]["itemIsFile"] and not pathFlags[index]["itemRemoved"] then
        logger.i("Removing " .. path)
        os.remove(path)
      end
    end
  end)
end

function addWatcher(pathToVolume)
  logger.i("Adding watcher for " .. pathToVolume)
  watchers[pathToVolume] = hs.pathwatcher.new(pathToVolume, junkWatcher):start()
end

function removeWatcher(pathToVolume)
  if watchers[pathToVolume] then
    logger.i("Removing watcher for " .. pathToVolume)
    watchers[pathToVolume]:stop()
    watchers[pathToVolume] = nil
  end
end

--
-- Listen to volume changes
--
hs.fs.volume
  .new(function(eventType, info)
    if eventType == hs.fs.volume.didMount then
      -- Add to patch watcher
      logger.i("Mounted volume at " .. info.path)
      addWatcher(info.path)
    end
    if eventType == hs.fs.volume.didUnmount then
      -- Add to patch watcher
      logger.i("Volume at " .. info.path .. " unmounted")
      removeWatcher(info.path)
    end
  end)
  :start()

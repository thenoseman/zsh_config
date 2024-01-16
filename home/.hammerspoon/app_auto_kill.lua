--
-- Install watcher for Apple Music
-- Automatically kill Apple Music if it opens (eg. when a bluetooth device connects)
--
local log = hs.logger.new("[app_auto_kill]", "debug")
local killBundleIds = { ["com.apple.Music"] = true }

function applicationWatcher(_, eventType, app)
  if killBundleIds[app:bundleID()] ~= nil and eventType == hs.application.watcher.launching then
    app:kill()
    log.i("Killed " .. app:bundleID())
  end
end

-- selene: allow(unscoped_variables)
-- selene: allow(unused_variable)
appWatcherMusic = hs.application.watcher.new(applicationWatcher)
appWatcherMusic:start()

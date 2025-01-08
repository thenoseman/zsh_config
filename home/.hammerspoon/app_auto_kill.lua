--
-- Install watcher for Apple Music
-- Automatically kill Apple Music if it opens (eg. when a bluetooth device connects)
--
local log = hs.logger.new("[app_kill]", "debug")
local killBundleIds = { ["com.apple.Music"] = true, ["com.apple.Terminal"] = true }

function applicationWatcher(_, eventType, app)
  if killBundleIds[app:bundleID()] ~= nil and eventType == hs.application.watcher.launching then
    app:kill()
    log.i("Killed " .. app:bundleID())

    -- Killing "Music" is done too late and results in player-pause being send to cmus in mediakeys.lua :(
    -- So we need to explicitly STOP cmus here
    -- selene: allow(undefined_variable)
    if app:bundleID() == "com.apple.Music" and cmus_remote_socket then
      log.i("[com.apple.Music] Sending command 'player-stop' to cmus socket")
      cmus_remote_socket:send("player-stop\n")
    end
  end
end

-- selene: allow(unscoped_variables)
-- selene: allow(unused_variable)
appWatcherMusic = hs.application.watcher.new(applicationWatcher)
appWatcherMusic:start()

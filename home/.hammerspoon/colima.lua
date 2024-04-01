--
-- Displays a nice icon in the menubar when colima is started
--
local log = hs.logger.new("[colima]", "debug")
local colimaPath = os.getenv("HOME") .. "/.colima"
local colimaPathDocker = colimaPath .. "/default/daemon/daemon.pid"
local menuBar = nil
local icon = hs.image.imageFromPath("media/colima.png"):setSize({ w = 18, h = 18 })
log.i("Watching " .. colimaPath .. " for changes")

function colimaMenuBar()
  menuBar = hs.menubar.new()
  menuBar:setTitle("")
  menuBar:setIcon(icon)
end

function colimaWatcher(paths, pathFlags)
  --- docker socker changed
  local index = hs.fnutils.indexOf(paths, colimaPathDocker)
  if index then
    if pathFlags[index]["itemRemoved"] then
      -- Colima has stopped
      log.i("colima has stopped")
      if menuBar then
        menuBar:delete()
        menuBar = nil
      end
    elseif pathFlags[index]["itemCreated"] then
      -- Colima has started
      log.i("colima has started")
      colimaMenuBar()
    end
  end
end

-- Startup check!
if hs.fs.attributes(colimaPathDocker, "size") then
  colimaMenuBar()
end

-- selene: allow(unused_variable, unscoped_variables)
colimaPathWatcher = hs.pathwatcher.new(colimaPath, colimaWatcher):start()

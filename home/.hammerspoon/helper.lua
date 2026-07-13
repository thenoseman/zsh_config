-- global helper
function file_exists(name)
  local f = io.open(name, "r")
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

function file_read(path)
  local file = io.open(path, "rb") -- r read mode and b binary mode
  if not file then
    return nil
  end
  local content = file:read("*a") -- *a or *all reads the whole file
  file:close()
  return content
end

function scriptDir()
  local str = debug.getinfo(1, "S").source
  local path = str:sub(2):match("(.*/)")
  return path
end

-- Hides any hs.chooser instances we know about that might be visible
-- (Seal's launcher, ClipboardToolSqlite's picker, ...).
--
-- This exists to work around a Hammerspoon bug where a visible hs.chooser
-- window gets "stuck" (unresponsive, unclosable) if the Lua environment is
-- torn down (e.g. via hs.reload()) while it is on screen:
-- https://github.com/Hammerspoon/hammerspoon/issues/3687
function hide_all_choosers()
  if spoon and spoon.Seal and spoon.Seal.chooser and spoon.Seal.chooser:isVisible() then
    spoon.Seal.chooser:hide()
  end
  if spoon and spoon.ClipboardToolSqlite and spoon.ClipboardToolSqlite.selectorobj then
    local chooser = spoon.ClipboardToolSqlite.selectorobj
    if chooser:isVisible() then
      chooser:hide()
    end
  end
end

-- Safe wrapper around hs.reload() that first hides any visible choosers,
-- to avoid https://github.com/Hammerspoon/hammerspoon/issues/3687
-- (a chooser left on screen during a reload gets stuck and unclosable
-- until Hammerspoon is quit).
function safe_reload()
  hide_all_choosers()
  -- Give the UI a beat to actually dismiss the chooser window(s) before we
  -- tear down the Lua environment.
  hs.timer.doAfter(0.05, function()
    hs.reload()
  end)
end

--
-- global helper
--
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

-- Safe wrapper around hs.reload() that first hides any visible choosers,
-- to avoid https://github.com/Hammerspoon/hammerspoon/issues/3687
function safe_reload()
  if spoon and spoon.Seal and spoon.Seal.chooser and spoon.Seal.chooser:isVisible() then
    spoon.Seal.chooser:hide()
  end

  if spoon and spoon.ClipboardToolSqlite and spoon.ClipboardToolSqlite.selectorobj then
    local chooser = spoon.ClipboardToolSqlite.selectorobj
    if chooser:isVisible() then
      chooser:hide()
    end
  end

  -- Give the UI a beat to actually dismiss the chooser window(s) before we
  -- tear down the Lua environment.
  hs.timer.doAfter(0.05, function()
    hs.reload()
  end)
end

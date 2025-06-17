-- selene: allow(unused_variable)
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

-- selene: allow(unused_variable)
function file_read(path)
  local file = io.open(path, "rb") -- r read mode and b binary mode
  if not file then
    return nil
  end
  local content = file:read("*a") -- *a or *all reads the whole file
  file:close()
  return content
end

-- selene: allow(unused_variable)
function scriptDir()
  local str = debug.getinfo(1, "S").source
  local path = str:sub(2):match("(.*/)")
  return path
end

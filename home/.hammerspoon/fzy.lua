local log = hs.logger.new("[fzy]", "debug")

-- Attempt to load the native version
local arch = io.popen("uname -m", "r"):read("*l")
log.i("Trying " .. "fzy_native_" .. arch .. ".so")
local ok, fzy_module = pcall(require, "fzy_native_" .. arch)

-- Otherwise, fall back on the lua version.
if not ok then
  log.i("Using lua version. Please compile the native binary for a speed boost.")
  hs.alert.show("Compile fzy native in $HOME/.hammerspoon/fzy using ./build.sh", {}, hs.screen.mainScreen(), 10)
  fzy_module = {}
else
  log.i("Using native version. Good.")
end

return fzy_module

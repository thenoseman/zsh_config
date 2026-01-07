--
-- Load the fzy fuzzy filter (fzf-like).
-- If it isn't compiled show some h
--
-- https://github.com/swarn/fzy-lua
--
local log = hs.logger.new("[fzy]", "debug")

-- Attempt to load the native version
local arch = io.popen("uname -m", "r"):read("*l")
local ok, fzy_module = pcall(require, "fzy_native_" .. arch)

-- Otherwise, fall back on the lua version.
if not ok then
  log.i("Using lua version. Please compile the native binary for a speed boost.")
  hs.alert.show("Compile fzy native in 'cd $HOME/.hammerspoon/fzy; ./build.sh'", {}, hs.screen.mainScreen(), 10)
  fzy_module = {}
else
  log.i("Using native version. Good.")
end

return fzy_module

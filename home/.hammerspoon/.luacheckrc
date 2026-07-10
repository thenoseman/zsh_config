-- luacheck configuration for Hammerspoon config
-- https://luacheck.readthedocs.io/en/stable/config.html

std = "lua53"

max_line_length = 180
max_comment_line_length = false

-- Hammerspoon injects a global `hs` table (and `spoon` for loaded Spoons)
globals = {
  "hs",
  "spoon",

  -- Hammerspoon `require`s all config files into the same global Lua
  -- state, so these are intentionally shared across files as globals.
  "SECRETS", -- init.lua -> translate_via_aws_translate.lua
  "file_exists", -- helper.lua -> init.lua, screen_layout.lua
  "file_read", -- helper.lua -> translate_via_aws_translate.lua
  "scriptDir", -- helper.lua
  "cmus_remote_socket", -- mediakeys.lua -> app_auto_kill.lua
  "holdreference", -- global table used across scripts to keep references alive and avoid garbage collection
  "primaryDisplay", -- screen_layout.lua -> layout/*.lua, resize_window_on_screen.lua
  "secondaryDisplay", -- screen_layout.lua -> layout/*.lua
  "terniaryDisplay", -- screen_layout.lua -> layout/*.lua
  "appWatcherTeams",
}

-- Third-party/vendored Spoons downloaded from
-- https://github.com/Hammerspoon/Spoons - not our code, don't lint.
exclude_files = {
  "Spoons/MouseCircle.spoon/",
  "Spoons/ReloadConfiguration.spoon/",
}

-- luacheck configuration for Hammerspoon config
-- https://luacheck.readthedocs.io/en/stable/config.html

std = "lua53"

-- Hammerspoon injects a global `hs` table (and `spoon` for loaded Spoons)
globals = {
  "hs",
  "spoon",
}

-- Third-party/vendored Spoons downloaded from
-- https://github.com/Hammerspoon/Spoons - not our code, don't lint.
exclude_files = {
  "Spoons/MouseCircle.spoon/",
  "Spoons/ReloadConfiguration.spoon/",
  "Spoons/Seal.spoon/",
}

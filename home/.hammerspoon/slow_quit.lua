-- Source: http://github.com/dbmrq/dotfiles/
-- Requires you to keep holding Command + Q for a while before closing an app,
-- so you won't do it accidentally.
-- Replaces apps like CommandQ and SlowQuitApps.

local alertStyle = {
  strokeWidth = 0,
  strokeColor = { white = 0, alpha = 0 },
  fillColor = { white = 0, alpha = 0 },
  textColor = hs.drawing.color["red"],
  textFont = "SF Pro Display Bold",
  textSize = 300,
  radius = 0,
  atScreenEdge = 0,
  fadeInDuration = 0.15,
  fadeOutDuration = 0.15,
  padding = -50,
}

-- How many seconds to wait until the app is killed
local delayInSeconds = 4

local secondsLeftUntilQuit = delayInSeconds
local killedIt = false
local timer
local alert

function holdQ()
  if secondsLeftUntilQuit <= 0 and not killedIt then
    killedIt = true
    timer:stop()
    hs.alert.closeSpecific(alert)
    hs.application.frontmostApplication():kill()
  end
end

function releaseQ()
  killedIt = false
  timer:stop()
  secondsLeftUntilQuit = delayInSeconds
  hs.alert.closeSpecific(alert)
end

function tick()
  hs.alert.closeSpecific(alert)
  alert = hs.alert.show(secondsLeftUntilQuit - 1, alertStyle, nil, 1)
  secondsLeftUntilQuit = secondsLeftUntilQuit - 1
end

function pressQ()
  killedIt = false
  timer = hs.timer.doEvery(0.5, tick)
  timer:fire()
end

hs.hotkey.bind("cmd", "Q", pressQ, releaseQ, holdQ)

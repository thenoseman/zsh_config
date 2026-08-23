-- volumeHUD.lua
-- Draws a macOS Sequoia-style volume HUD using hs.canvas (vector speaker icon)

local SEGMENTS = 16
local HUD_W = 280
local HUD_H = 280
local HUD_CORNER = 24
local SEG_H = 7
local HIDE_DELAY = 1.5

local BG_COLOR = { red = 0.29, green = 0.29, blue = 0.29, alpha = 0.9 }
local SEG_ON = { red = 1, green = 1, blue = 1, alpha = 0.90 }
local SEG_OFF = { red = 1, green = 1, blue = 1, alpha = 0.20 }

local canvas = nil
local hideTimer = nil

-- Returns an arc polyline (open, not closed) centred at cx,cy with given radius,
-- from startAngle to endAngle (radians), with `steps` segments.
local function arc(cx, cy, r, startAngle, endAngle, steps)
  local pts = {}
  for i = 0, steps do
    local a = startAngle + (endAngle - startAngle) * i / steps
    pts[i + 1] = { x = cx + r * math.cos(a), y = cy + r * math.sin(a) }
  end
  return pts
end

local function showHUD()
  local dev = hs.audiodevice.defaultOutputDevice()
  local volume = (dev and not dev:muted()) and (dev:volume() or 0) or 0
  local FILLED = math.floor(volume / 100 * SEGMENTS + 0.5)
  local screen = hs.screen.mainScreen()
  local sf = screen:frame()
  local x = sf.x + (sf.w - HUD_W) / 2
  local y = sf.y + (sf.h - HUD_H) / 2

  if canvas then
    canvas:delete()
  end
  canvas = hs.canvas.new({ x = x, y = y, w = HUD_W, h = HUD_H })

  local idx = 0
  local function add(el)
    idx = idx + 1
    canvas[idx] = el
  end

  -- Background
  add({
    type = "rectangle",
    action = "fill",
    fillColor = BG_COLOR,
    roundedRectRadii = { xRadius = HUD_CORNER, yRadius = HUD_CORNER },
    frame = { x = 0, y = 0, w = HUD_W, h = HUD_H },
  })

  -- ── Vector speaker icon ──────────────────────────────────────────────────
  -- All coordinates in a 100×100 unit space, centred in the HUD.
  -- Icon occupies roughly the top 60% of the HUD.
  local IS = 110 -- icon bounding size in points
  local OX = (HUD_W - IS) / 2 -- top-left x of icon area
  local OY = (HUD_H - IS) / 2 - 18 -- top-left y of icon area
  -- helper: map from 0-100 unit space to canvas coords
  local function p(ux, uy)
    return { x = OX + ux * IS / 100, y = OY + uy * IS / 100 }
  end
  local function px(ux)
    return OX + ux * IS / 100
  end
  local function py(uy)
    return OY + uy * IS / 100
  end

  -- Speaker body: pentagon (left rect + right trapezoid fused as polygon)
  -- Body rect: x 20–38, y 34–66
  -- Cone:      x 38–52, y 22–78  (wider at right)
  add({
    type = "segments",
    action = "fill",
    fillColor = SEG_ON,
    closed = true,
    coordinates = {
      p(20, 36),
      p(20, 64), -- left edge of body
      p(38, 64),
      p(52, 78), -- bottom of cone
      p(52, 22), -- top of cone
      p(38, 36), -- top of body
    },
  })

  -- Sound waves — count depends on volume level
  if volume > 0 then
    local cx = px(60)
    local cy = py(50)
    local span = math.pi * 0.40
    local allRadii = { IS * 0.2, IS * 0.30, IS * 0.40 }
    local allWidths = { 4.5, 4.0, 3.5 }
    local waveCount = 1
    if volume > 20 then
      waveCount = 2
    end
    if volume > 50 then
      waveCount = 3
    end

    for i = 1, waveCount do
      add({
        type = "segments",
        action = "stroke",
        strokeColor = SEG_ON,
        strokeWidth = allWidths[i],
        strokeCapStyle = "round",
        closed = false,
        coordinates = arc(cx, cy, allRadii[i], -span, span, 20),
      })
    end
  end

  -- ── Segmented bar ────────────────────────────────────────────────────────
  local barW = HUD_W * 0.82
  local barX = (HUD_W - barW) / 2
  local barY = HUD_H - 38
  local gap = barW / SEGMENTS
  local segW = gap * 0.70
  local lit = math.max(0, math.min(SEGMENTS, FILLED))

  for i = 1, SEGMENTS do
    add({
      type = "rectangle",
      action = "fill",
      fillColor = (i <= lit) and SEG_ON or SEG_OFF,
      frame = { x = barX + (i - 1) * gap, y = barY, w = segW, h = SEG_H },
      roundedRectRadii = { xRadius = 2, yRadius = 2 },
    })
  end

  canvas:level(hs.canvas.windowLevels.overlay)
  canvas:show()

  if hideTimer then
    hideTimer:stop()
  end
  hideTimer = hs.timer.doAfter(HIDE_DELAY, function()
    if canvas then
      canvas:delete()
      canvas = nil
    end
  end)
end

-- Intercept volume keys via systemDefined events (same as media keys)
holdreference.keyTap = hs.eventtap.new({ hs.eventtap.event.types.systemDefined }, function(e)
  local data = e:systemKey()
  if not data then
    return false
  end
  if data["key"] == "SOUND_UP" or data["key"] == "SOUND_DOWN" or data["key"] == "MUTE" then
    -- Cancel any pending hide immediately so the HUD doesn't vanish mid-press
    if hideTimer then
      hideTimer:stop()
      hideTimer = nil
    end
    hs.timer.doAfter(0.05, showHUD)
  end
  return false
end)
holdreference.keyTap:start()

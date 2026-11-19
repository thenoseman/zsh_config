-- ============================================================================
-- vpn health monitor for Hammerspoon
-- ============================================================================
-- Menubar icon shows:
--   Green   — healthy (all three checks pass)
--   Orange  — process + interface up, target unreachable
--   Red     — openconnect process not running
--   Amber   — process running but tunnel interface missing
-- ============================================================================

local CONFIG = {
  target = SECRETS.openconnect_healthcheck_fqdn,
  checkInterval = 90,
  pingCount = 2,
  pingInterval = 1.0,
  pingTimeout = 3.0,
  notifyTimeout = 10,
}

local menubar = hs.menubar.new(true, "⚪")
local timer = hs.timer
local notify = hs.notify
local task = hs.task
local pingModule = hs.network.ping
local logger = hs.logger.new("🕸️", "info")
local notified = false
local lastNotification = 0
local currentPing = nil
local scheduleNotification
local pingResultHandlers = {}

-- ===========================================================================
-- Menubar setup
-- ===========================================================================
local statusIcons = {
  healthy = "🟢",
  no_interface = "🟡",
  degraded = "🟠",
  down = "🔴",
  unknown = "⚪",
}

local function updateMenubar(newStatus)
  menubar:setTitle(statusIcons[newStatus] or statusIcons.unknown)
  menubar:setTooltip("vpn: " .. tostring(newStatus))
end

function pingResultHandlers.pingSuccess(_host)
  updateMenubar("healthy")
  scheduleNotification(true)
end

function pingResultHandlers.pingFailure(_host, _sent)
  updateMenubar("degraded")
  scheduleNotification(false)
end

-- ===========================================================================
-- Notifications
-- ===========================================================================
scheduleNotification = function(isHealthy)
  local now = hs.timer.secondsSinceEpoch()

  if isHealthy then
    notified = false
    return
  end

  if not notified or (now - lastNotification) > CONFIG.notifyTimeout then
    notify.show("vpn", "Connection degraded", string.format("%s unreachable via VPN", CONFIG.target), function()
      runHealthCheck(true)
    end)
    notified = true
    lastNotification = now
  end
end

-- ===========================================================================
-- System check (process + tunnel interface in one shell call)
-- ===========================================================================
local sysCheckCmd = [==[
  if pgrep -x openconnect >/dev/null 2>&1; then
    if netstat -rn | grep '10\.109\.' | grep -qE '(utun|gpd)'; then
      echo "proc=1,tunnel=1"
    else
      echo "proc=1,tunnel=0"
    fi
  else
    echo "proc=0"
  fi
]==]

local function checkSystem(callback)
  task
    .new("/opt/homebrew/bin/bash", function(exitCode, stdout)
      if exitCode ~= 0 then
        callback("error", false, false)
        return
      end

      local result = stdout or ""
      if result:match("proc=0") then
        callback("down", false, false)
      elseif result:match("tunnel=0") then
        callback("no_interface", true, false)
      else
        callback("ok", true, true)
      end
    end, { "-c", sysCheckCmd })
    :start()
end

local function pingTarget(host)
  if currentPing and currentPing:isRunning() then
    currentPing:cancel()
  end

  currentPing = pingModule(
    host,
    CONFIG.pingCount,
    CONFIG.pingInterval,
    CONFIG.pingTimeout,
    "IPv4",
    function(pingObj, msg)
      if msg == "didFinish" then
        local summary = pingObj:summary()
        local sent, received = summary:match("(%d+) packets transmitted, (%d+) packets received")
        sent = tonumber(sent)
        received = tonumber(received)
        local success = (sent and received and sent > 0 and sent == received)

        if success then
          pingResultHandlers.pingSuccess(host)
        else
          pingResultHandlers.pingFailure(host, sent, received)
        end

        currentPing = nil
      end
    end
  )
end

-- ===========================================================================
-- Health check: system check
-- ===========================================================================
local function runHealthCheck()
  checkSystem(function(phase)
    if phase == "down" then
      updateMenubar("down")
      scheduleNotification(false)
      return
    end

    if phase == "no_interface" then
      updateMenubar("no_interface")
      scheduleNotification(false)
      return
    end

    pingTarget(CONFIG.target)
  end)
end

--
-- Only on some computers
--
if string.find(string.lower(hs.host.localizedName()), "m2", 2, true) then
  timer.doEvery(CONFIG.checkInterval, function()
    logger.i("Running periodic health check")
    runHealthCheck()
  end)

  updateMenubar("unknown")
  logger.i("vpn monitor loaded - check every " .. CONFIG.checkInterval .. "s")
  logger.i("Target: " .. CONFIG.target)

  timer.doAfter(2, function()
    runHealthCheck()
  end)
end

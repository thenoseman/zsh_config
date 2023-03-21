--
-- https://libretranslate.com/
--
local popup_size = hs.geometry.size(600, 350)
local logger = hs.logger.new("🎙", "debug")

local headers = {
  ["Content-Type"] = "application/json",
  ["origin"] = "https://libretranslate.com",
  ["user-agent"] = "curl/7.79.1",
  ["accept"] = "*/*",
}

local popup_style = hs.webview.windowMasks.utility
  | hs.webview.windowMasks.HUD
  | hs.webview.windowMasks.titled
  | hs.webview.windowMasks.closable

local rect = hs.geometry.rect(0, 0, popup_size.w, popup_size.h)
rect.center = hs.screen.mainScreen():frame().center
local webview = hs.webview.new(rect)
webview:allowTextEntry(true):windowStyle(popup_style):closeOnEscape(true):windowTitle("translation")
local hammerspoon_app = hs.application.applicationsForBundleID(hs.processInfo.bundleID)[1]

function current_selection()
  local elem = hs.uielement.focusedElement()
  local sel = nil
  if elem then
    sel = elem:selectedText()
  end
  if (not sel) or (sel == "") then
    hs.eventtap.keyStroke({ "cmd" }, "c")
    hs.timer.usleep(20000)
    sel = hs.pasteboard.getContents()
  end
  return (sel or "")
end

function prepare_html(translation, from)
  -- selene: allow(undefined_variable)
  local template = file_read(os.getenv("HOME") .. "/.hammerspoon/translate.html")
  template = string.gsub(template, "<translation />", translation)
  template = string.gsub(template, "<translation_from />", from)
  return template
end

function translateSelectionPopup(text)
  if not text then
    text = current_selection()
  end

  -- First fetch the "secret"
  local status_code, response = hs.http.get("https://libretranslate.com/js/app.js?v=" .. os.time())
  local secret = string.match(response, 'apiSecret: "(%w+)"')

  local body = '{"q":"'
    .. text
    .. '","source":"auto","target":"de","format":"text","api_key":"","secret":"'
    .. secret
    .. '"}'
  local status_code, response = hs.http.post("https://libretranslate.com/translate", body, headers)

  if status_code == 200 then
    --[[
    {
    "detectedLanguage": {
        "confidence": 92,
        "language": "en"
    },
    "translatedText": "durchgestrichen"
    }
    --]]
    local translated_from = hs.json.decode(response)["detectedLanguage"]["language"]
    local translation = hs.json.decode(response)["translatedText"]
    local h = prepare_html(translation, translated_from)
    webview:html(h):bringToFront(true):show()

    -- Bring the window in focus so ESC works as expected
    local window = hammerspoon_app:getWindow("translation")
    hammerspoon_app:activate()
    window:focus()
  else
    logger.e("Unable to request translation, status code=" .. status_code .. ", response = " .. response)
  end
end

hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "t", translateSelectionPopup)

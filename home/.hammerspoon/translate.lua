--
-- https://libretranslate.com/
--
local popup_size = hs.geometry.size(600, 350)
local logger = hs.logger.new("🎙", "debug")

local headers = {
  ["Content-Type"] = "application/json",
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

function prepare_html(translation, from, original)
  -- selene: allow(undefined_variable)
  local template = file_read(os.getenv("HOME") .. "/.hammerspoon/translate.html")
  template = string.gsub(template, "<translation />", translation)
  template = string.gsub(template, "<translation_from />", from)
  return template
end

local function isempty(s)
  return s == nil or s == ""
end

function translateSelectionPopup(text)
  if isempty(text) then
    text = current_selection()
  end

  local body = '{"q":"' .. string.gsub(text, '"', '\\"') .. '","source":"auto","target":"de","format":"text"}'
  local status_code, response = hs.http.post(SECRETS.libre_translate_api_url .. "/translate", body, headers)

  if status_code == 200 then
    --[[
    {
      "detectedLanguage": {
          "confidence": 83,
          "language": "en"
      },
      "translatedText": "Prüfung"
    }
    --]]
    --
    local translated_from = hs.json.decode(response)["detectedLanguage"]["language"]
    local translation = hs.json.decode(response)["translatedText"]
    local h = prepare_html(translation, translated_from, text)
    webview:html(h):bringToFront(true):show()

    -- Bring the window in focus so ESC works as expected
    local window = hammerspoon_app:getWindow("translation")
    hammerspoon_app:activate()
    window:focus()
  else
    hs.alert.show("Error translating")
    logger.e("Unable to request translation, status code=" .. status_code .. ", response = " .. response)
  end
end

hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "t", translateSelectionPopup)

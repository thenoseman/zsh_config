local popup_size = hs.geometry.size(600, 350)
local logger = hs.logger.new("🎙", "debug")

local headers = {
  ["Content-Type"] = "application/json",
  ["Ocp-Apim-Subscription-Key"] = SECRETS.azure_translate_api_key,
  ["Ocp-Apim-Subscription-Region"] = "germanywestcentral",
  ["Accept"] = "application/json",
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
  local post = '[{"text":"' .. text .. '"}]'

  local status_code, response =
    hs.http.post("https://api.cognitive.microsofttranslator.com/translate?api-version=3.0&to=de", post, headers)

  if status_code == 200 then
    --[[
    [
      {
        "detectedLanguage": { "language": "ru", "score": 1.0 },
        "translations": [
          { "text": "Test", "to": "de" }
        ]
      }
    ]
    --]]
    local translated_from = hs.json.decode(response)[1]["detectedLanguage"]["language"]
    local translation = hs.json.decode(response)[1]["translations"][1]["text"]
    local h = prepare_html(translation, translated_from)
    webview:html(h):bringToFront(true):show()

    -- Bring the window in focus so ESC works as expected
    local window = hammerspoon_app:getWindow("translation")
    hammerspoon_app:activate()
    window:focus()
  else
    logger.e("Unable to request translation, status code=" .. status_code)
  end
end

hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "t", function()
  translateSelectionPopup()
end)

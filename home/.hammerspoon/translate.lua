-- local popup_size = hs.geometry.size(770, 310)
-- local popup_style = hs.webview.windowMasks.utility
--   | hs.webview.windowMasks.HUD
--   | hs.webview.windowMasks.titled
--   | hs.webview.windowMasks.closable
local logger = hs.logger.new("🎙", "debug")

local headers = {
  ["Content-Type"] = "application/json",
  ["Ocp-Apim-Subscription-Key"] = SECRETS.azure_translate_api_key,
  ["Ocp-Apim-Subscription-Region"] = "germanywestcentral",
  ["Accept"] = "application/json",
}

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
    local translation = hs.json.decode(response)[1]["translations"][1]["text"]

    local screen_center = hs.screen.mainScreen():frame().center
    local popup_size = { x = 600, y = 400 }
    hs.dialog.alert(
      screen_center.x - (popup_size.x / 2),
      screen_center.y - (popup_size.y / 2),
      function() end,
      "Translation:",
      translation,
      "ok",
      nil,
      "informational"
    )
  else
    logger.e("Unable to request translation, status code=" .. status_code)
  end
end

translateSelectionPopup()

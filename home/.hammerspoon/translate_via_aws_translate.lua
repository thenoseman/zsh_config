--
-- https://libretranslate.com/
--
local popup_size = hs.geometry.size(600, 350)
local logger = hs.logger.new("🎙", "debug")

-- Headers to add on all requests
local headers = {
  ["Content-Type"] = "application/json",
}

local default_target_language = "de"
local default_target_language_if_source_default = "en"

-- Style of webview popup
-- See https://github.com/Hammerspoon/hammerspoon/blob/master/extensions/webview/libwebview.m#L2528
local popup_style = hs.webview.windowMasks.utility
  | hs.webview.windowMasks.HUD
  | hs.webview.windowMasks.titled
  | hs.webview.windowMasks.closable

local rect = hs.geometry.rect(0, 0, popup_size.w, popup_size.h)
rect.center = hs.screen.mainScreen():frame().center
local webview = hs.webview.new(rect)
webview:allowTextEntry(true):windowStyle(popup_style):closeOnEscape(true):windowTitle("translation")

--local hammerspoon_app = hs.application.applicationsForBundleID(hs.processInfo.bundleID)[1]
local hammerspoon_app = hs.application.find("org.hammerspoon.Hammerspoon")

--
-- return the current selected text or ""
--
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

--
-- Substitute values into template
--
function prepare_html(translation, from, original)
  -- selene: allow(undefined_variable)
  local template = file_read(os.getenv("HOME") .. "/.hammerspoon/translate.html")
  template = string.gsub(template, "<translation />", translation)
  template = string.gsub(template, "<translation_from />", from)
  return template
end

---
--- "" or nil
---
local function isempty(s)
  return s == nil or s == ""
end

function translate(text, target_language)
  local url = SECRETS.aws_translate_lambda_url
    .. "?sourceLanguage=auto&targetLanguage="
    .. target_language
    .. "&text="
    .. hs.http.encodeForQuery(string.gsub(string.gsub(text, '"', '\\"'), "\n", " "))

  logger.i("Calling " .. url)

  local status_code, response = hs.http.get(url, headers)

  logger.i("Response:")
  logger.i(response)
  local r = {
    translated_from = nil,
    translation = nil,
  }

  if status_code == 200 then
    --[[
    {"source":"es","target":"en","text":"This is a text in Spanish"}
    --]]
    r.translated_from = hs.json.decode(response)["source"]
    r.translation = hs.json.decode(response)["text"]
  else
    hs.alert.show("Error translating: status_code = " .. status_code)
    logger.e("Unable to request translation, status code=" .. status_code .. ", response = " .. response)
  end

  return r
end

function translateSelectionPopup(text, target_language)
  if isempty(text) then
    text = current_selection()
  end

  -- Default is to translate into "default_target_language"
  if isempty(target_language) then
    target_language = default_target_language
  end

  hs.alert("Translating ...")
  logger.i("Translating text to '" .. target_language .. "'")

  local translation = translate(text, target_language)
  -- If the detected language is the default language translate it into the default_target_language_if_source_default
  if translation.translated_from == default_target_language then
    logger.i(
      "Source was '"
        .. translation.translated_from
        .. "' now switching to target '"
        .. default_target_language_if_source_default
        .. "'"
    )
    translation = translate(text, default_target_language_if_source_default)
  end

  hs.alert.closeAll()

  local h = prepare_html(translation.translation, translation.translated_from, text)
  webview:html(h):bringToFront(true):show()

  -- Bring the window in focus so ESC works as expected
  local window = hammerspoon_app:getWindow("translation")
  hammerspoon_app:activate()
  window:focus()
end

hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "t", translateSelectionPopup)

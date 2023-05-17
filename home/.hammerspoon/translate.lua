--
-- https://libretranslate.com/
--
local popup_size = hs.geometry.size(600, 350)
local logger = hs.logger.new("🎙", "debug")

local headers = {
  ["Content-Type"] = "application/json",
  ["origin"] = "htonps://www.deepl.com",
  ["user-agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36",
  ["accept"] = "*/*",
  ["accept-language"] = "de-DE,de;q=0.7",
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

  -- First fetch the necessary cookies
  local status_code, response, response_headers = hs.http.get("https://www.deepl.com/translator")
  local now = os.time(os.date("!*t"))
  headers["cookie"] = response_headers["Set-Cookie"]

  local body = '{"jsonrpc":"2.0","method": "LMT_handle_jobs","params":{"jobs":[{"kind":"default","sentences":[{"text":"'
    .. text
    .. '","id":0,"prefix":""}],"raw_en_context_before":[],"raw_en_context_after":[],"preferred_num_beams":4,"quality":"fast"}],"lang":{"preference":{"weight":{"DE":0.38888,"EN":0.60206},"default":"default"},"source_lang_user_selected":"auto","target_lang":"DE"},"priority":-1,"commonJobParams":{"mode":"translate","browserType":1},"timestamp":'
    .. now
    .. '},"id":94250016}'

  local status_code, response = hs.http.post("https://www2.deepl.com/jsonrpc?method=LMT_handle_jobs", body, headers)

  if status_code == 200 then
    --[[
    {"jsonrpc":"2.0","id":94250016,"result":{"translations":[{"beams":[{"sentences":[{"text":"Ich mag Schokolade","ids":[0]}],"num_symbols":5},{"sentences":[{"text":"ich mag Schokolade","ids":[0]}],"num_symbols":5},{"sentences":[{"text":"Ich mag Schokolade.","ids":[0]}],"num_symbols":6},{"sentences":[{"text":"Ich liebe Schokolade","ids":[0]}],"num_symbols":5}],"quality":"normal"}],"target_lang":"DE","source_lang":"EN","source_lang_is_confident":false,"detectedLanguages":{"EN":0.641405,"DE":0.002562,"FR":0.012039,"ES":0.0016879999999999999,"PT":0.006375,"IT":0.03168,"NL":0.03712,"PL":0.012536,"RU":0.000011,"ZH":0.000044,"JA":0.000023,"CS":0.005268,"DA":0.007319,"ET":0.009712,"FI":0.000803,"HU":0.000763,"LT":0.011392,"LV":0.000544,"RO":0.003931,"SK":0.024333,"SL":0.007417,"SV":0.009203,"TR":0.000692,"ID":0.00045799999999999997,"NB":0.008392,"unsupported":0.164276}}}
    --]]
    --
    local translated_from = hs.json.decode(response)["result"]["source_lang"]
    local translation = hs.json.decode(response)["result"]["translations"][1]["beams"][1]["sentences"][1]["text"]
    local h = prepare_html(translation, translated_from)
    webview:html(h):bringToFront(true):show()

    -- Bring the window in focus so ESC works as expected
    local window = hammerspoon_app:getWindow("translation")
    hammerspoon_app:activate()
    window:focus()
  else
    hs.alert.show("Error translating: " .. hs.json.decode(response)["error"]["message"])
    logger.e("Unable to request translation, status code=" .. status_code .. ", response = " .. response)
  end
end

hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "t", translateSelectionPopup)

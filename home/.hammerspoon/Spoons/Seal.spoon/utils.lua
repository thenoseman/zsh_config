local fzy = require("fzy")

local boldAttr = { font = { name = "Helvetica-Bold", size = 16 } }

local function highlightMatches(text, query)
  local styledText = hs.styledtext.new(text)
  local positions = fzy.positions(query, text)
  if positions then
    for _, pos in ipairs(positions) do
      styledText = styledText:setStyle(boldAttr, pos, pos)
    end
  end
  return styledText
end

local function starts_with(str, start)
  return str:sub(1, #start) == start
end

local function fuzzyMatch(query, haystack)
  local matches = fzy.filter(query, haystack)

  -- Sort by score descending
  table.sort(matches, function(a, b)
    return (a[3] > b[3])
  end)
  -- Take first 10 matches
  matches = table.move(matches, 1, 10, 1, {})

  -- Convert indices to the cache entries
  return hs.fnutils.imap(matches, function(match)
    return haystack[match[1]]
  end)
end

return {
  highlightMatches = highlightMatches,
  starts_with      = starts_with,
  fuzzyMatch       = fuzzyMatch,
}

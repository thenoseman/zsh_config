-- global helper
function file_exists(name)
   local f = io.open(name,"r")
   if f ~= nil then 
     io.close(f) 
     return true 
   else 
     return false 
   end
end

require "spoons"
require "screen_layout"
require "audio"
require "msteams"
require "hotkeys"
require "mediakeys"

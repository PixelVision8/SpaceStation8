--[[
    ## Space Station 8 `utils.lua`

    The `utils.lua` file contains some common functions our game will need in order to run. These help functions add additional functionality onto base types or can be used to help assist when debugging your code.
    
    Learn more about making Pixel Vision 8 games at http://docs.pixelvision8.com
]]--

-- The `PadLeft()` function will add a specified number of characters to the left of a supplied string. This function augments the string primitive and add the ability to call padLeft directly on it like the other built in Lua string functions.
function string.padLeft(str, len, char)

    -- Use the built in `string.rep()` function to add the right number of characters to the left of the supplied string.
    return string.rep(char or ' ', len - #str) .. str

end


function MessageBuilder(words)

    local message = {"", {}}
  
    for i = 1, #words do
      
      local word = words[i][1]
      local color = words[i][2]
  
      message[1] = message[1] .. word
  
      for j = 1, #word do
        table.insert(message[2], color)
      end
  
    end
  
    return message
    
  end

function GetButtonMapping(button)

    local useController = ControllerConnected(0)

    if(button == Buttons.Left) then
        return "<"
    elseif(button == Buttons.Right) then
        return ">"
    elseif(button == Buttons.A) then
        return useController and "A" or "X"
    elseif(button == Buttons.B) then
        return useController and "B" or "C"
    elseif(button == Buttons.Select) then
        return useController and "-" or "A"
    elseif(button == Buttons.Start) then
        return useController and "+" or "S"
    end

end
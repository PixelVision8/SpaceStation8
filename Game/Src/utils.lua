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
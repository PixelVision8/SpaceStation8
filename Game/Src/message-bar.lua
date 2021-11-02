--[[
    ## Space Station 8 `menu.lua`

    The the `menu.lua` script is a collection of functions that manage a bar of text at the top of the game's screen. This can be used to display different messages to instruct the player what to do on each scene.
]]--

-- We need to create a table to store all of the scene's functions.
MessageBar = {}
MessageBar.__index = MessageBar

-- This constant stores the name of the timer the menu uses.
local MENU_TIMER = "messageTimer"

function MessageBar:Init(y)

    -- This table contains all of the settings for the menu including the font, text color offset, position, maximum characters and the clear color.
    local messageBar = {
        textColorOffset = 3,
        font = "medium",
        pos = NewPoint(0, y),
        textPos = NewPoint(0,y),
        maxChars = Display().X/4,
        offset = -4,
        clearColorID = 0
    }

    -- Each instance of the menu bar will needs its own timer so we use the `MENU_TIMER` constant plus the menu's position to create a unique name for the timer.
    messageBar.timerId = MENU_TIMER .. messageBar.pos.ToString()

    setmetatable(messageBar, MessageBar) -- make Account handle lookup

    return messageBar

end

-- This `Update()` function manges checking to see if the timer has been triggered and when to clear the menu message.
function MessageBar:Update(timeDelta)

    -- Check to see if the time's value is less than or equip to zero. If so, exit out of the update function since the menu should stay permanently visible.
    if(TimerDelay(self.timerId) == -1) then

        -- Exit out of the menu update so the message stays visible on the display.
        return;

    end

    -- Check to see if the timer has been triggered and clear the message.
    if(TimerTriggered(self.timerId)) then

        -- Call clear message to remove the message from the display.
        self:ClearMessage()

    end

end

-- The `Draw()` function handles clearing the background and displaying the menu's message text on the display.
function MessageBar:Draw()
    
    -- Check to see if the menu has been invalidated and should be redrawn.
    if(self.invalid == true) then
        
        -- Draw a rectangle behind the message text to clear the menu area.
        DrawRect( 
          self.pos.x,
          self.pos.y,
          self.maxChars * 4,
          8,
          self.clearColorID,
          DrawMode.TilemapCache
        )
        
        -- Draw the menu text on top of the bar that was just drawn.
        DrawColoredText(
          self.currentMessage,
          self.textPos.x,
          self.textPos.y,
          DrawMode.TilemapCache,
          self.font,
          self.textColorOffsets,
          self.offset
        )
        
        -- One thing to point out about drawing text to the display is that you can change the color via the color offset argument and the spacing between characters by modifying the offset argument. By default both of these values are set to 0. Making the offset negative, each character will be drawn closer to each other.
    
        -- Reset the menu invalid flag since the text was just drawn to the display. This also ensures we are not redrawing the menu on each frame unless it has been changed in some way.
        self.invalid = false
    end

end

-- The `DisplayMessage()` function draws the menu text to the display. It accepts a string of text, a time in milliseconds to remain visible for, and whether the text should be centered in the menu or not.
function MessageBar:DisplayMessage(value, time, centered, onClearCallback)

    -- In order to display a message we need text and color offsets. We'll use these two variables to store these once we break down the `value` argument.
    local text = ""
    local colorOffsets = {self.textColorOffset}

    -- In order for us to use the `DrawColoredText()` API, we need an array of color offsets to tell the renderer which color to use for each character. By default, the `DrawColoredText()` API will use the last color offset it find so by creating an array with a single color offset, we can ensure that the text is always drawn with message bar's default color offset in the `textColorOffset` variable.

    -- Since Lua doesn't support overload functions, we need to check to see if the `value` argument is a string or a table.
    if(type(value) == "string") then

        -- Since the value is a string, we can just set it to the `text` variable and use the default color offset.
        text = value

    -- Now we need to test if the `value` argument is a table.
    elseif(type(value) == "table") then
        
        -- Since the value is a table, we need to pull out the first item which is the text and the second item which is the color offset array.
        text = value[1]
        colorOffsets = value[2]

    end

    -- We want to make sure that we only display the message if the text is not already being displayed so we check to see if the `text` matches the `currentMessage`.
    if(self.currentMessage == text) then

        -- Exit out of the function since the message is already displayed.
        return;

    end

    -- We'll save the any function passed in as a callback so we can call it later when the menu is cleared.
    self.callBack = onClearCallback

    -- Lua allows us to pass references to a function which we can then call later. This is useful for when we want to call a function whenever some kind of specific event occurs such as when we clear the menu.
    
    -- Before we display the message, we need to make sure it's note longer than what the menu can display. Here we test the length of the text string to the menu's maxChars value.
    if(#text > self.maxChars) then

        -- If the new message text length is greater than the maxChars we truncate it by the max character value
        text = string.sub(text, 1, self.maxChars)

    end

    -- Set the new text as the currentMessage text and change it to uppercase.
    self.currentMessage = text
    self.textColorOffsets = colorOffsets

    -- Test to see if the text should be centered.
    if(centered ~= false) then

        -- In Lua you can test variable even if it has been created yet. Since `centered` is an option argument that we want to default to false, we can simple check that centered doesn't equal false.

        -- We can center the text by measuring the width of the display, minus the width of the text (taking into account that each character is 4 pixels wide) and then halving it by multiplying the number by .5.
        self.textPos.X = (Display().X - (#text * 4)) * .5

    end

    -- This will create a new timer or reset an existing one. We'll set the key to the `MENU_TIMER` constant and supply the time argument.
    NewTimer(self.timerId, time)

    -- The time argument for `DisplayMessage()` uses milliseconds to determine how long to stay visible on the display. For example, if you want to show a message for 2 seconds, you would pass in 2000 as the time value. Likewise, if you set the time value to -1, it will disable the timer and the text will remain on the display until the menu is cleared or a new message is passed in.

    -- Since we have changed the text and updated the time, we need to invalidate the entire menu so it will render on correctly on the next frame.
    self.invalid = true

end

-- The `ClearMessage()` function will set the text message to an empty string and turn the timer off.
function MessageBar:ClearMessage()

    local lastCallback = self.callBack

    -- Here we the call `DisplayMessage()` and pass in the empty string and `-1` for he time.
    self:DisplayMessage("", -1)

    -- Now that the timer has run out and the message has been cleared, we need to look to see if there is a value for our `callback` property.
    if(lastCallback ~= nil) then

        -- If a function has been assigned to the `callback` property, we need to call it.
        lastCallback()

        -- Originally I had thought of putting this in the `Update()` function so it was only triggered when the timer ran out but there may be a scenario where a new message clears a previous one and we'll want to know when that happens. We also need to trigger the callback function before we call `DisplayMessage()` since passing in an empty string to clear it will also set the `callback` property to nil.

    end

end
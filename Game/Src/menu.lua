--[[
    ## Space Station 8 `menu.lua`

    The the `menu.lua` script is a collection of functions that manage a bar of text at the top of the game's screen. This can be used to display different messages to instruct the player what to do on each scene.
]]--

-- This table contains all of the settings for the menu including the font, text color offset, position, maximum characters and the clear color.
local menuData = {
    textColorOffset = 3,
    font = "medium",
    pos = NewPoint(0, -1),
    textPos = NewPoint(0,-1),
    maxChars = Display().X/4 - 2,
    offset = -4,
    clearColorID = 0
  }

-- This constant stores the name of the timer the menu uses.
local MENU_TIMER = "messageTimer"

-- This `Update()` function manges checking to see if the timer has been triggered and when to clear the menu message.
function UpdateMenu(timeDelta)

    -- Check to see if the time's value is less than or equip to zero. If so, exit out of the update function since the menu should stay permanently visible.
    if(TimerDelay(MENU_TIMER) == -1) then

        -- Exit out of the menu update so the message stays visible on the display.
        return;

    end

    -- Check to see if the timer has been triggered and clear the message.
    if(TimerTriggered(MENU_TIMER)) then

        -- Call clear message to remove the message from the display.
        ClearMessage()

    end

end

-- The `Draw()` function handles clearing the background and displaying the menu's message text on the display.
function DrawMenu()
    
    -- Check to see if the menu has been invalidated and should be redrawn.
    if(menuData.invalid == true) then
        
        -- Draw a rectangle behind the message text to clear the menu area.
        DrawRect( 
          menuData.pos.x,
          menuData.pos.y,
          menuData.maxChars * 4,
          8,
          menuData.clearColorID,
          DrawMode.TilemapCache
        )
        
        -- Draw the menu text on top of the bar that was just drawn.
        DrawText(
          menuData.currentMessage,
          menuData.textPos.x,
          menuData.textPos.y,
          DrawMode.TilemapCache,
          menuData.font,
          menuData.textColorOffset,
          menuData.offset
        )
        
        -- One thing to point out about drawing text to the display is that you can change the color via the color offset argument and the spacing between characters by modifying the offset argument. By default both of these values are set to 0. Making the offset negative, each character will be drawn closer to each other.
    
        -- Reset the menu invalid flag since the text was just drawn to the display. This also ensures we are not redrawing the menu on each frame unless it has been changed in some way.
        menuData.invalid = false
    end

end

-- The `DisplayMessage()` function draws the menu text to the display. It accepts a string of text, a time in milliseconds to remain visible for, and whether the text should be centered in the menu or not.
function DisplayMessage(text, time, centered)

    -- The time argument for `DisplayMessage()` uses milliseconds to determine how long to stay visible on the display. For example, if you want to show a message for 2 seconds, you would pass in 2000 as the time value. Likewise, if you set the time value to -1, it will disable the timer and the text will remain on the display until the menu is cleared or a new message is passed in.

    -- Before we display the message, we need to make sure it's note longer than what the menu can display. Here we test the length of the text string to the menu's maxChars value.
    if(#text > menuData.maxChars) then

        -- If the new message text length is greater than the maxChars we truncate it by the max character value
        text = string.sub(text, 1, menuData.maxChars)

    end

    -- Set the new text as the currentMessage text and change it to uppercase.
    menuData.currentMessage = string.upper(text)

    -- Test to see if the text should be centered.
    if(centered ~= false) then

        -- In Lua you can test variable even if it has been created yet. Since `centered` is an option argument that we want to default to false, we can simple check that centered doesn't equal false.

        -- We can center the text by measuring the width of the display, minus the width of the text (taking into account that each character is 4 pixels wide) and then halving it by multiplying the number by .5.
        menuData.textPos.X = (Display().X - (#text * 4)) * .5

    end

    -- This will create a new timer or reset an existing one. We'll set the key to the `MENU_TIMER` constant and supply the time argument.
    NewTimer(MENU_TIMER, time)

    -- Since we have changed the text and updated the time, we need to invalidate the entire menu so it will render on correctly on the next frame.
    menuData.invalid = true

end

-- The `ClearMessage()` function will set the text message to an empty string and turn the timer off.
function ClearMessage()
   
    -- Here we the call `DisplayMessage()` and pass in the empty string and `-1` for he time.
    DisplayMessage("", -1)

end
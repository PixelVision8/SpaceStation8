--[[
    ## Space Station 8 `editor-plugin-brush.lua`

]]

INPUT_TIMER = "InputTimer"
BLINK_TIMER = "BlinkTimer"

NewTimer(INPUT_TIMER, 100)
NewTimer(BLINK_TIMER, 500)

local brushCanvas = NewCanvas(8, 8)
brushCanvas:SetStroke(4, 1)
brushCanvas:DrawRectangle(0, 0, brushCanvas.Width, brushCanvas.Height)

-- Create the plugin table
local editorPlugin = {
    name = "brush"
}

-- Add an update function to the table
editorPlugin.Update = function(editor, timeDelta)

    if(editor.mode ~= MODE_DRAW) then
        return
    end

    if(editor.brushPos == nil) then
        editor.brushPos = NewPoint(Display().C * .5, (Display().R * .5) - 2)
    end

    -- Check for input delay
    if(TimerTriggered(INPUT_TIMER)) then
    
        if(Button(Buttons.Up)) then

            editor.brushPos.R = editor.brushPos.R - 1

            if(editor.brushPos.R <= 0) then
                editor.brushPos.R = Display().R-1
            end

        elseif(Button(Buttons.Down)) then

            editor.brushPos.R = Clamp(Repeat(editor.brushPos.R + 1, Display().R), 1, Display().R-1)

        elseif(Button(Buttons.Right)) then

            editor.brushPos.C = Repeat(editor.brushPos.C + 1, Display().C)

        elseif(Button(Buttons.Left)) then

            editor.brushPos.C = Repeat(editor.brushPos.C - 1, Display().C)

        -- elseif(Button(Buttons.Select)) then

            -- editor:SelectTile(Repeat(editor.currentTile + 1, Display().C))

        end

    end

    if(Button(Buttons.A) == true) then

        if(editor.brushPos.R == Display().R-1 ) then
            editor:SelectTile(editor.brushPos.C)
        else
            editor:DrawTile(editor.brushPos.C, editor.brushPos.R)
        end
    
    end

    -- Always check for the button release independent of the timer
    if(Button(Buttons.B, InputState.Released)) then

        editor:FlipTile()

    end

    if(TimerTriggered(BLINK_TIMER) == true) then

        if(editor.blink == nil) then
            editor.blink = true
        else
            editor.blink = not editor.blink
        end
        
    end
    

end

editorPlugin.Draw = function(editor, timeDelta)

    if(editor.mode ~= MODE_DRAW or editor.brushPos == nil) then

        return

    end

    -- Draw the cursor
    if(editor.blink == true and editor.brushPos.R < Display().R-1) then

        -- Mask off the background
        DrawRect(editor.brushPos.X, editor.brushPos.Y, 8, 8, BackgroundColor(), DrawMode.Sprite)

        -- Draw the currently selected tile
        DrawSprite(editor.spriteId, editor.brushPos.X, editor.brushPos.Y, false, false, DrawMode.Sprite)

    end

    brushCanvas:DrawPixels(editor.brushPos.X, editor.brushPos.Y, DrawMode.Sprite)
   
    -- Draw selected tile background
    DrawRect(editor.selectionX, Display().Y - 9, 8, 9, 3, DrawMode.Sprite)

    -- Draw selected tile
    DrawSprite(editor.spriteId, editor.selectionX, Display().Y - 8, false, false, DrawMode.Sprite)

end

return editorPlugin
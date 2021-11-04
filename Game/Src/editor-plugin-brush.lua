--[[
    ## Space Station 8 `editor-plugin-cursor.lua`

]]

BLINK_TIMER = "BlinkTimer"

local cursorCanvas = NewCanvas(8, 8)
cursorCanvas:SetStroke(4, 1)
cursorCanvas:DrawRectangle(0, 0, cursorCanvas.Width, cursorCanvas.Height)

NewTimer(BLINK_TIMER, 500)

local cursorBounds = NewRect(0, 1, (Display().C) - 1, (Display().R) - 2)

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

            editor.brushPos.Y = editor.brushPos.Y - 1

            if(editor.brushPos.Y < cursorBounds.Top) then
            editor.brushPos.Y = cursorBounds.Bottom
            end

        elseif(Button(Buttons.Down)) then

            editor.brushPos.Y = editor.brushPos.Y + 1

            if(editor.brushPos.Y > cursorBounds.Bottom) then
            editor.brushPos.Y = cursorBounds.Top
            end

        end

        if(Button(Buttons.Right)) then

            editor.brushPos.X = editor.brushPos.X + 1

            if(editor.brushPos.X > cursorBounds.Right) then
            editor.brushPos.X = cursorBounds.Left
            end

        elseif(Button(Buttons.Left)) then

            editor.brushPos.X = editor.brushPos.X - 1

            if(editor.brushPos.X < cursorBounds.Left) then
            editor.brushPos.X = cursorBounds.Right
            end

        elseif(Button(Buttons.Select)) then

            editor:SelectTile(Repeat(editor.currentTile + 1, 20))

        end

    end

    if(Button(Buttons.A) == true) then

        if(editor.brushPos.Y < cursorBounds.Bottom ) then
            editor:DrawTile(editor.brushPos.X, editor.brushPos.Y)
        else
            editor:SelectTile(editor.brushPos.X)
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

    -- Make sure the cursor is in the bounds
    editor.brushPos.X = Clamp(editor.brushPos.X, cursorBounds.Left, cursorBounds.Right)
    editor.brushPos.Y = Clamp(editor.brushPos.Y, cursorBounds.Top, cursorBounds.Bottom)

    editor.tileId = editor.currentTile + 1
    editor.selectionX = (editor.tileId - 1) * 8

    editor.spriteId = editor.tiles[editor.currentTile + 1][editor.altTile == false and 1 or 2]

end

editorPlugin.Draw = function(editor, timeDelta)

    if(editor.mode ~= MODE_DRAW or editor.brushPos == nil) then

        return

    end

    -- if(editor.hideBrush ~= false) then

    local cursorX = editor.brushPos.X * 8
    local cursorY = editor.brushPos.Y * 8

    -- Draw the cursor
    if(editor.blink == true and editor.brushPos.Y < cursorBounds.Bottom) then

        -- Mask off the background
        DrawRect(cursorX, cursorY, 8, 8, BackgroundColor(), DrawMode.Sprite)

        -- Draw the currently selected tile
        DrawSprite(editor.spriteId, cursorX, cursorY, false, false, DrawMode.Sprite)

    end

    cursorCanvas:DrawPixels(cursorX, cursorY, DrawMode.Sprite)
    
    -- else

    --     DrawRect(editor.brushPos.X * 8, Display().Y - 9, 8, 1, 3, DrawMode.UI)
    
    -- end
    
    -- Draw selected tile background
    DrawRect(editor.selectionX, Display().Y - 9, 8, 9, 3, DrawMode.Sprite)

    -- Draw selected tile
    -- DrawSprite(self.spriteId, self.selectionX, Display().Y - 8, false, false, DrawMode.Sprite)
    
    -- Draw selected tile
    DrawSprite(editor.spriteId, editor.selectionX, Display().Y - 8, false, false, DrawMode.Sprite)

    -- end

end

return editorPlugin
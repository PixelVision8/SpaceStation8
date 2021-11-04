--[[
    ## Space Station 8 `editor-plugin-mouse.lua`

]]
MOUSE_TIMER = "MouseTimer"

local mouseBounds = NewRect(0, 1, (Display().C) - 1, (Display().R) - 3)


-- Create the plugin table
local editorPlugin = {
    name = "mouse"
}

-- Add an update function to the table
editorPlugin.Update = function(editor, timeDelta)

  if(editor.mode ~= MODE_DRAW) then
    return
  end

  if(editor.brushPos == nil) then
    editor.brushPos = NewPoint(0, 0)
  end

  -- Update all of the cursor and selection values
  if(TimerTriggered(MOUSE_TIMER) == true) then
    
    ClearTimer(MOUSE_TIMER)
    editor.showMouse = false

  end

  if(MouseButton(1, InputState.Released)) then

    editor:FlipTile()

  end

  -- We need to capture the mouse's position on this frame incase we need to display the cursor.
  local newMousePos = MousePosition()
  
  -- We need to reset the mouse timer if we detect a change from the last `X` or `Y` position.
  if(editor.lastMousePos == nil or editor.lastMousePos.X ~= newMousePos.X or editor.lastMousePos.Y ~= newMousePos.Y) then

    -- Here we are going to save the current mouse position so we have a reference of it in the next frame.
    editor.lastMousePos = newMousePos

    -- Since we have detected a change in the mouse's movement, we need to reset the timer.
    -- self.mouseTime = 1000

    -- We can reset the timer by calling the `NewTimer()` API. We pass in the `MOUSE_TIMER` string as the timer name and the `1000` as the time in milliseconds.
    NewTimer(MOUSE_TIMER, 1000)

    editor.showMouse = true

    -- It's important to note that Pixel Vision 8 pools timers. If a timer with the same name already exists, it's delay value will simply be updated and the timer will be reset. This is helpful to avoid creating lots of timers but can be problematic if you have different conditions looking at the same timer.

  end

  if(editor.showMouse == true) then
    -- self.mouseTime = self.mouseTime - (1000 * (timeDelta/1000))

    editor.brushPos.X = math.floor((editor.lastMousePos.X) / 8)
    editor.brushPos.Y = math.floor((editor.lastMousePos.Y) / 8)

  end

  if(editor.lastMousePos.Y > (Display().Y - 8)) then

  --   editor.hideBrush = true

    if(MouseButton(0, InputState.Released)) then

      editor.currentTile = editor.brushPos.X
    end

  elseif(editor.brushPos.Y <= mouseBounds.Bottom) then

  --   editor.hideBrush = false

    if(MouseButton(0) ==  true) then

      editor:DrawTile(editor.brushPos.X, editor.brushPos.Y)
      
    end

  end

end

editorPlugin.Draw = function(editor)

  -- Exit out of this if we are not in the draw mode
  if(editor.mode ~= MODE_DRAW) then
    return
  end
  
  if(TimerValue(MOUSE_TIMER) > 0) then

    DrawMetaSprite("cursor", editor.lastMousePos.X, editor.lastMousePos.Y, false, false, DrawMode.Mouse)

  end

end

return editorPlugin
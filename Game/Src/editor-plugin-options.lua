--[[
    ## Space Station 8 `editor-plugin-options.lua`

]]

-- Create the plugin table
local editorPlugin = {
    name = "cursor"
}

-- Add an update function to the table
editorPlugin.Update = function(editor, timeDelta)

  -- print("Running", editor.mode, MODE_DRAW)
  
  -- We only want to test for opening the option window if we are in the draw mode
  if(editor.mode == MODE_DRAW and Button(Buttons.Start, InputState.Released)) then

    local title = MessageBuilder
    (
      {
        {" PLAY", 3},
        {"(", 1},
        {GetButtonMapping(Buttons.A), 2},
        {") ", 1},
        {"BACK", 3},
        {"(", 1},
        {GetButtonMapping(Buttons.B), 2},
        {") ", 1},
        {"RENAME", 3},
        {"(", 1},
        {GetButtonMapping(Buttons.Select), 2},
        {") ", 1},
        {"EXIT", 3},
        {"(", 1},
        {GetButtonMapping(Buttons.Start), 2},
        {")", 1},
        {"+", 3},
        {"(", 1},
        {GetButtonMapping(Buttons.Select), 2},
        {")", 1},
      }
    )

    DisplayTitle(title, -1, true)

    -- DrawRect(editor.selectionX, Display().Y - 9, 8, 9, 3, DrawMode.Sprite)

    DisplayMessage(mapLoader:GetMapName(), -1, false)


    editor.optionsOpen = true

    editor.mode = MODE_OPTIONS
    
  end
  
  if(editor.mode == MODE_OPTIONS) then

    if(Button(Buttons.A, InputState.Released)) then
        
      SwitchScene(RUN)
  
    elseif(Button(Buttons.B, InputState.Released)) then
  
      -- In order to close the option menu we just need to change the `mode` back to `MODE_EDIT`.
      editor.mode = MODE_DRAW

      editor:DrawEditorUI()
  
    elseif(Button(Buttons.Select, InputState.Released)) then
      
      if(Button(Buttons.Start, InputState.Released)) then
        SwitchScene(SPLASH)
      else
        editor.rename = true
        
        editor.mode = MODE_RENAME
      end
  
    end

  end

end

return editorPlugin
--[[
    ## Space Station 8 `editor-plugin-options.lua`

]]

-- Create the plugin table
local editorPlugin = {
    name = "options",
    mapName = ""
}

-- Add an update function to the table
editorPlugin.Update = function(editor, timeDelta)

  -- We only want to test for opening the option window if we are in the draw mode
  if(editor.mode == MODE_DRAW) then

    if(Button(Buttons.Select, InputState.Released)) then

        local title = MessageBuilder
        (
          {
            -- {" PLAY", 3},
            -- {"(", 1},
            -- {GetButtonMapping(Buttons.A), 2},
            -- {") ", 1},
            {"BACK", 3},
            {"(", 1},
            {GetButtonMapping(Buttons.B), 2},
            {") ", 1},
            -- {"RENAME", 3},
            -- {"(", 1},
            -- {GetButtonMapping(Buttons.Select), 2},
            -- {") ", 1},
            {"QUIT", 3},
            {"(", 1},
            {GetButtonMapping(Buttons.Start), 2},
            {")", 1},
            -- {"+", 3},
            -- {"(", 1},
            -- {GetButtonMapping(Buttons.Select), 2},
            -- {")", 1},
          }
        )

        DisplayTitle(title, -1, true)

        -- Need to save this name if we need to edit it later
        editorPlugin.mapName = mapLoader:GetMapName()

        DisplayMessage(editorPlugin.mapName, -1, false)

        editor.mode = MODE_OPTIONS

      end
    
    elseif(editor.mode == MODE_OPTIONS) then

      -- if(Button(Buttons.A, InputState.Released)) then
          
      --   SwitchScene(RUN)

      -- else
      if(Button(Buttons.Select, InputState.Released)) then
          
        editor.mode = MODE_RENAME

        local title = MessageBuilder
        (
          {
            {" SELECT", 3},
            {"(", 1},
            {GetButtonMapping(Buttons.A), 2},
            {") ", 1},
            {"DELETE", 3},
            {"(", 1},
            {GetButtonMapping(Buttons.B), 2},
            {") ", 1},
            {"NEXT", 3},
            {"(", 1},
            {GetButtonMapping(Buttons.Up), 2},
            {") ", 1},
            {"SAVE", 3},
            {"(", 1},
            {GetButtonMapping(Buttons.Select), 2},
            {") ", 1},
          }
        )

        DisplayTitle(title, -1, true)

        -- Need to save this name if we need to edit it later
        editorPlugin.mapName = mapLoader:GetMapName()

        DisplayMessage(editorPlugin.mapName, -1, false)

        editor.mode = MODE_OPTIONS
    
      elseif(Button(Buttons.B, InputState.Released)) then
    
        -- In order to close the option menu we just need to change the `mode` back to `MODE_EDIT`.
        editor.mode = MODE_DRAW

        editor:DrawEditorUI()
    
      elseif(Button(Buttons.Start, InputState.Released)) then
        
        -- if(Button(Buttons.Start, InputState.Released)) then
          SwitchScene(SPLASH)
        -- else
        --   editor.rename = true
          
        --   editor.mode = MODE_RENAME
        -- end
    
      end

    elseif(editor.mode == MODE_RENAME) then
  
      -- TODO need to capture text input

      

    end
end


return editorPlugin
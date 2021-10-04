--[[
  Pixel Vision 8 - ReaperBoy v2
  Copyright (C) 2017, Pixel Vision 8 (http://pixelvision8.com)
  Created by Jesse Freeman (@jessefreeman)

  Licensed under the Microsoft Public License (MS-PL) License.

  Learn more about making Pixel Vision 8 games at http://pixelvision8.com
]]--

-- Load scenes
LoadScript("scene-loader")
LoadScript("scene-splash")
LoadScript("scene-editor")
LoadScript("scene-over")
LoadScript("scene-game")

-- Modes
LOADER, SPLASH, EDITOR, RUN, OVER = 1, 2, 3, 4, 2 -- TODO need to create an OVER screen

-- Create a variable to store the active scene
local activeScene = nil

local activeSceneId = 1

-- The Init() method is part of the game's lifecycle and called a game starts. We are going to
-- use this method to configure background color, ScreenBufferChip and draw a text box.
function Init()

  MaskColor(Color(2))

  -- Change the background
  BackgroundColor(2)
  
  -- Create a table for each of the scenes that make up the game
  scenes = {
    LoaderScene:Init(),
    SplashScene:Init(),
    EditorScene:Init(),
    GameScene:Init(),
    -- OverScene:Init()
  }

  -- Switch to the first scene
  SwitchScene(LOADER)

end

function SetSystemColor()

  -- look to see what key combination is pressed

  local dir = nil

  if( Button(0) == true) then
    dir = 1
  elseif( Button(1) == true) then
    dir = 2
  elseif( Button(2) == true) then
    dir = 3
  elseif( Button(3) == true) then
    dir = 4
  end

  local button = nil

  if( Button(4) == true) then
    button = 1
  elseif( Button(5) == true) then
    button = 2
  end

  local offset = 0

  if(dir ~= nil) then

    offset = dir * 4

    if(button ~= nil) then
      offset = offset + (button * 16)
    end

  end

  for i=0,3 do
    ReplaceColor(i, i + offset)
  end

end

function SwitchScene(id)

  activeSceneId = id

  -- Set the new active scene
  activeScene = scenes[activeSceneId]

  -- Call reset on the new active scene
  activeScene:Reset()

end

-- The Update() method is part of the game's life cycle. The engine calls Update() on every frame
-- before the Draw() method. It accepts one argument, timeDelta, which is the difference in
-- milliseconds since the last frame.
function Update(timeDelta)

  -- On first run, check to see if the system colors should be changed
  if(firstRun == nil)then

    SetSystemColor()

    firstRun = false

  end

  -- Check to see if there is an active scene before trying to update it.
  if(activeScene ~= nil) then
    activeScene:Update(timeDelta)
  end

  if(Key(Keys.Escape, InputState.Released)) then

    SaveState()
    
    -- TODO need to save the current tilemap
    LoadGame("/PixelVisionOS/Tools/SettingsTool/")

  end


end

-- The Draw() method is part of the game's life cycle. It is called after Update() and is where
-- all of our draw calls should go. We'll be using this to render sprites to the display.
function Draw()

  -- We can use the RedrawDisplay() method to clear the screen and redraw the tilemap in a
  -- single call.
  RedrawDisplay()

  -- Check to see if there is an active scenes before trying to draw it.
  if(activeScene ~= nil) then
    activeScene:Draw()
  end

end

function SaveState()
  
  -- Save the current session ID
  WriteSaveData("sessionID", SessionID())

  -- Make sure we don't save paths in the tmp directory
  WriteSaveData("lastSceneId", activeSceneId)

  WriteSaveData("lastState", activeScene:SaveState())
 
  -- Save the current selection
  -- WriteSaveData("selection", (self.windowIconButtons ~= nil and editorUI:ToggleGroupSelections(self.windowIconButtons)[1] or 0))


  -- local history = ""

  -- for key, value in pairs(self.pathHistory) do
  --   -- print("key", key, dump(value))

  --   history = history .. key .. ":" .. value.scrollPos .. (value.selection == nil and "" or ("," .. value.selection.Path)) .. ";"

  -- end

  -- -- Make sure we don't save paths in the tmp directory
  -- WriteSaveData("history", history)

end

-- Global function to help calculate the tile position from an ID
function TilePosFromIndex(index, width)
  return index % width, math.floor(index / width)
end

-- Utilities
function LeftPad(str, len, char)
  if char == nil then char = ' ' end
  return string.rep(char, len - #str) .. str
end

function dump(o)
  if type(o) == 'table' then
    local s = '{ '
    for k, v in pairs(o) do
      if type(k) ~= 'number' then k = '"'..k..'"' end
      s = s .. '['..k..'] = ' .. dump(v) .. ','
    end
    return s .. '} '
  else
    return tostring(o)
  end
end

function OnLoadImage(value)

  if(activeSceneId == SPLASH or activeSceneId == LOADER) then
    -- print("OnLoadImage Called", value.Width, value.Height)

    value.RemapColors({MaskColor(),Color(0), Color(1), Color(2), Color(3)})

    scenes[LOADER].defaultMapImage = value

    SwitchScene(LOADER)

  end

  -- DrawPixels(value.GetPixels(), 0, 0, value.Width, value.Height, false, false, DrawMode.TilemapCache)

end

local lastImagePath = "/User/Levels/map.spacestation8.png"

function SaveLevel(newPath)

  if(newPath) then
    
    lastImagePath = UniqueFilePath(newPath)
    
  end

  local mapImage = NewCanvas(TilemapSize().X * 8, TilemapSize().Y * 8)

  
  -- Copy the tilemap to the canvas
  local total = TilemapSize().X * TilemapSize().Y

  for i = 1, total do

    local pos = CalculatePosition(i-1, TilemapSize().X)
    local sprite = Tile(pos.X, pos.Y).SpriteId

    mapImage.DrawSprite(sprite, pos.X * 8, pos.Y * 8)

  end

  -- Draw the UI on top of the image
  mapImage.DrawMetaSprite("top-bar", 0, 0)

  local message = "PLAY AT SPACESTATION8.DOWNLOAD"
  mapImage.DrawText(message, (Display().X - (#message * 4)) * .5, -1, "medium", 3, -4)

  mapImage.DrawMetaSprite("tile-picker", 0, (TilemapSize().Y - 2) * 8)

  local tmpImage = NewImage(mapImage.Width, mapImage.Height, mapImage.GetPixels(), {MaskColor(),Color(0), Color(1), Color(2), Color(3)})




  -- local mapImage = NewCanvas(TilemapSize().X * 8, TilemapSize().Y * 8)

  --       local total = TilemapSize().X * TilemapSize().Y

  --       for i = 1, total do

  --         local pos = CalculatePosition(i-1, TilemapSize().X)
  --         local sprite = Tile(pos.X, pos.Y).SpriteId

  --         mapImage.DrawSprite(sprite, pos.X * 8, pos.Y * 8)

  --       end
        
  --       local tmpImage = NewImage(mapImage.Width, mapImage.Height, mapImage.GetPixels(), {MaskColor(),Color(0), Color(1), Color(2), Color(3)})
      
  --       SaveImage(scenes[LOADER].imagePath, tmpImage)

  SaveImage(lastImagePath, tmpImage)

end

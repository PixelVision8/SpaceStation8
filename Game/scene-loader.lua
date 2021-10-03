--[[
  Pixel Vision 8 - ReaperBoy v2
  Copyright (C) 2017, Pixel Vision 8 (http://pixelvision8.com)
  Created by Jesse Freeman (@jessefreeman)

  Licensed under the Microsoft Public License (MS-PL) License.

  Learn more about making Pixel Vision 8 games at http://pixelvision8.com
]]--

-- Splash Scene
LoaderScene = {}
LoaderScene.__index = LoaderScene

function LoaderScene:Init()

  local _loader = {
    flickerTime = 0,
    flickerDelay = 400,
    flickerVisible = true,
    -- Load the image using the bg as the mask
    mapImage = ReadImage(NewWorkspacePath("/Game/template.png"), Color(2)) -- TODO need to figure out how to pass an image into this
  }

  setmetatable(_loader, LoaderScene) -- make Account handle lookup

  return _loader

end

function LoaderScene:Reset()

  -- Remap the colors to the system colors
  self.mapImage.RemapColors({MaskColor(),Color(0), Color(1), Color(2), Color(3)})

  -- Calculate the columns and rows
  local cols = math.floor(self.mapImage.Width/8)
  local rows = math.floor(self.mapImage.Height/8)

  -- Change the background
  BackgroundColor(2)

  -- Make sure the image is the correct size
  if(cols < 20 or rows < 19) then

    DrawText("There was an error loading the image.", 4, 0, DrawMode.TilemapCache, "medium", 3, -4)
    DrawText("Please make sure it's 160 x 144 pixels.", 4, 8, DrawMode.TilemapCache, "medium", 3, -4)

    return

  end

  -- Calculate how far from the bottom we want to sample from
  local spriteOffset = 16

  -- Create a rect for the sample area
  local sampleSize = NewRect(0,self.mapImage.Height - spriteOffset, self.mapImage.Width, spriteOffset)

  -- Create a new image with just the footer tiles
  local tiles = NewImage(sampleSize.Width, sampleSize.Height, self.mapImage.GetPixels(sampleSize.X, sampleSize.Y, sampleSize.Width, sampleSize.Height))
  
  -- Capture 2 columns of sprites
  local totalSprites = cols * 2

  -- Id of the sprite we are working with
  local id = 0

  -- Loop through all the sprites
  for i = 1, totalSprites do
    
    -- Find the source column and row
    local pos = CalculatePosition(i-1, cols)

    -- Copy over the pixel data to the canvas
    local pixels = tiles.GetPixels(pos.X * 8, pos.Y * 8, 8, 8)
    
    -- Save the sprite pixel data (this overwrites the first font)
    Sprite(id, pixels)

    -- Increment the sprite Id
    id = id + 1

  end

  -- Clear the tilemap
  ClearTilemap()

  -- Rebuild the Tilemap by hand
  local totalTiles = cols * rows

  -- Loop through all of the tiles staring at the second row
  for i = 2, totalTiles do
    
    local pos = CalculatePosition(i-1, cols)
    local pixels = self.mapImage.GetPixels(pos.X * 8, pos.Y * 8, 8, 8)

    local spriteId = FindSprite(pixels)

    if(spriteId > -1) then
      Tile(pos.X, pos.Y, spriteId)
    end

  end

  -- Build out all of the meta sprites the game needs to run
  NewMetaSprite("player", {2, 20, 26, 27, 22})
  NewMetaSprite("enemy", {3, 24, 23})
  NewMetaSprite("tile-picker", 
  {
    0,  1,  2, 3, 4, 5, 6, 7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
    0, 21, 22, 23, 4, 25, 6, 7, 28, 29, 30, 31, 32, 13, 14, 15, 16, 17, 18, 19,
  }, 20)
  NewMetaSprite("solid", {4, 5, 6, 8, 17, 18, 19, 25, 28})
  NewMetaSprite("falling-platform", {7})
  NewMetaSprite("door-open", {1})
  NewMetaSprite("door-closed", {21})
  NewMetaSprite("spike", {11, 31})
  NewMetaSprite("switch-off", {13})
  NewMetaSprite("switch-on", {33})
  NewMetaSprite("ladder", {14})
  NewMetaSprite("key", {15})
  NewMetaSprite("gem", {16})
  NewMetaSprite("ui-o2", {33, 34, 34, 34, 35}, 5)
  NewMetaSprite("ui-key", {38, 39})
  NewMetaSprite("ui-life", {36, 37})


  -- TODO ned  to restore selections correctly
  local nextSceneId = SPLASH
  
  if(SessionID() == ReadSaveData("sessionID", "")) then
    nextSceneId = tonumber(ReadSaveData("lastSceneId", tostring(SPLASH)))
  end

  SwitchScene(nextSceneId)

end

function LoaderScene:Update(timeDelta)


end

function LoaderScene:Draw()

  -- if(Button(Buttons.Start)) then
    
  --   for i = 1, 96 do
    
  --     local pos = CalculatePosition(i-1, 20)
  --     local id = i-1
  --     DrawText(tostring((id < 10 and "0" or "") .. id), pos.X * 8, pos.Y * 8, DrawMode.Sprite, "medium", 3, -4)

  --   end

  -- end

  -- if(self.flickerVisible == true) then
  --   DrawText("      START FOR EDITOR    DROP MAP HERE", 3, Display().Y- 9, DrawMode.Sprite, "medium", 3, -4)
  -- end
  

end

function LoaderScene:SaveState()
  
  return "GameScene State"

end

function LoaderScene:RestoreState(value)
  
  print("Restore state", state)

end

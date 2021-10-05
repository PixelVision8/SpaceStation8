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
    imagePath = NewWorkspacePath("/Game/map.spacestation8.png"),
  }

  -- Load the image using the bg as the mask
  _loader.defaultMapImage = ReadImage(_loader.imagePath, Color(2))

  -- Remap the colors of the template image when first loaded
  _loader.defaultMapImage.RemapColors({MaskColor(),Color(0), Color(1), Color(2), Color(3)})

  setmetatable(_loader, LoaderScene) -- make Account handle lookup

  return _loader

end

function LoaderScene:Reset()

  DrawRect(0, 0, Display().X, Display().Y, BackgroundColor())

  -- Remap the colors to the system colors
  

  -- Calculate the columns and rows
  local cols = math.floor(self.defaultMapImage.Width/8)
  local rows = math.floor(self.defaultMapImage.Height/8)

  -- Make sure the image is the correct size
  if(cols < 20 or rows < 17) then

    
    DrawText("There was an error loading the image.", 4, 0, DrawMode.TilemapCache, "medium", 3, -4)
    DrawText("Please make sure it's 160 x 136 pixels.", 4, 8, DrawMode.TilemapCache, "medium", 3, -4)

    return

  end

  -- Create a new map image
  local mapImage = NewCanvas(Display().X, Display().Y + 8)

  -- Restore default sprites
  local defaultSprites = ReadImage(NewWorkspacePath("/Game/sprites.png"), Color(2))
  defaultSprites.RemapColors({MaskColor(),Color(0), Color(1), Color(2), Color(3)})
  mapImage.SetPixels(0, mapImage.Height - 16, defaultSprites.Width, defaultSprites.Height, defaultSprites.GetPixels())

  -- Copy over the tilemap image
  mapImage.SetPixels(0, 0, self.defaultMapImage.Width, self.defaultMapImage.Height, self.defaultMapImage.GetPixels())

  -- Calculate how far from the bottom we want to sample from
  local spriteOffset = 16

  -- Create a rect for the sample area
  local sampleSize = NewRect(0,mapImage.Height - spriteOffset, mapImage.Width, spriteOffset)

  -- Create a new image with just the footer tiles
  local tiles = NewImage(sampleSize.Width, sampleSize.Height, mapImage.GetPixels(sampleSize.X, sampleSize.Y, sampleSize.Width, sampleSize.Height))
  
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
    local pixels = mapImage.GetPixels(pos.X * 8, pos.Y * 8, 8, 8)

    local spriteId = FindSprite(pixels)

    if(spriteId > -1) then
      Tile(pos.X, pos.Y, spriteId)
    end

  end

  -- Build out all of the meta sprites the game needs to run
  NewMetaSprite("player", {
    2, 27, -- Idle (1)
    24, 2, -- Walking (2)
    25, 25,-- Jumping/Climbing (3)
    26, -- Falling (5)
    21 -- Alt sprite (used when drawing in the tilemap)
  })

  -- Create constants for player animations
  PLAYER_IDLE, PLAYER_WALK, PLAYER_JUMP, PLAYER_CLIMB, PLAYER_FALL = 1, 2, 3, 3, 4

  -- Manually flip the climbing sprite so it animates
  MetaSprite("player").Sprites[4].FlipH = true

  NewMetaSprite("enemy", {3, 22, 23})

  NewMetaSprite("enemy-move", {3, 23})

  -- Border
  NewMetaSprite("top-bar", {38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38}, 20)
  NewMetaSprite("bottom-bar", {39, 39, 39, 39, 39, 39, 39, 39, 39, 39, 39, 39, 39, 39, 39, 39, 39, 39, 39, 39}, 20)
  

  -- Tile Editor
  NewMetaSprite("tile-picker", {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
                                20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39}, 20)

  NewMetaSprite("bottom-hud", {39, 39, 39, 39, 39, 39, 39, 35, 37, 37, 37, 37, 37, 39, 39, 39, 39, 39, 39, 39}, 20)
  
  -- O2 Bar
  -- NewMetaSprite("ui-o2-bar", {35, 37, 37, 37, 37, 37}, 6)
  NewMetaSprite("ui-o2-border", {36}, 1)


  -- Collectables
  NewMetaSprite("ui-key", {15})
  NewMetaSprite("ui-life", {24})
  NewMetaSprite("cursor", {34})

  -- Flag Tiles
  NewMetaSprite("solid", {4, 5, 6, 8, 17, 18, 19, 28})
  NewMetaSprite("platform", {7})
  NewMetaSprite("door-open", {1})
  NewMetaSprite("door-locked", {20})
  NewMetaSprite("spike", {9, 29})
  NewMetaSprite("switch-off", {13})
  NewMetaSprite("switch-on", {33})
  NewMetaSprite("ladder", {14})
  NewMetaSprite("key", {15})
  NewMetaSprite("gem", {16})



  -- TODO ned  to restore selections correctly
  -- local nextSceneId = 
  
  -- if(SessionID() == ReadSaveData("sessionID", "")) then
  --   nextSceneId = tonumber(ReadSaveData("lastSceneId", tostring(SPLASH)))
  -- end

  -- self.imagePath = UniqueFilePath(NewWorkspacePath())

  SaveLevel(NewWorkspacePath("/User/Levels/" .. self.imagePath.EntityName))

  SwitchScene(SPLASH)

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
  
  -- print("Restore state", state)

end

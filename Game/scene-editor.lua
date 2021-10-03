--[[
  Pixel Vision 8 - ReaperBoy v2
  Copyright (C) 2017, Pixel Vision 8 (http://pixelvision8.com)
  Created by Jesse Freeman (@jessefreeman)

  Licensed under the Microsoft Public License (MS-PL) License.

  Learn more about making Pixel Vision 8 games at http://pixelvision8.com
]]--

-- Splash Scene
EditorScene = {}
EditorScene.__index = EditorScene

function EditorScene:Init()

  local _editor = {
    cursorPos = NewPoint(0, 0),
    cursorOffset = NewPoint(),
    cursorBounds = NewRect(0, 1, Display().X/8 - 1, Display().Y/8 - 3),
    currentTile = 0,
    cursorCanvas = NewCanvas(8, 8),
    inputTime = 0,
    inputDelay = 100,
    blinkTime = 0,
    blinkDelay = 500,
    blink = false,
    altTile = false,
    cursorX = 0,
    cursorY = 0,
    tileId = 0,
    selectionX = 0,
    spriteId = 0
  }
  setmetatable(_editor, EditorScene) -- make Account handle lookup

  return _editor

end

function EditorScene:Reset()

  self.cursorCanvas:SetStroke(4, 1)
  self.cursorCanvas:DrawRectangle(0, 0, self.cursorCanvas.Width, self.cursorCanvas.Height)

  -- Create UI
  DrawRect(0, 0, Display().X, 7, 0)
  DrawRect(0, Display().Y - 8, Display().X, 8, 2)
  

  DrawText("PLAY       TILE       DRAW     FLIP    ", 3, -1, DrawMode.TilemapCache, "medium", 3, -4)
  DrawText("      STR        SEL        A        B", 3, -1, DrawMode.TilemapCache, "medium", 2, -4)
  DrawText("     [   ]      [   ]      [ ]      [ ]", 3, -1, DrawMode.TilemapCache, "medium", 1, -4)

  DrawMetaSprite("tile-picker", 0, Display().Y - 8, false, false, DrawMode.TilemapCache)

end

function EditorScene:Update(timeDelta)

  self.inputTime = self.inputTime + timeDelta

  if(self.inputTime > self.inputDelay) then
    
    self.inputTime = 0

    if(Button(Buttons.Up)) then

      self.cursorPos.Y = self.cursorPos.Y - 1

      if(self.cursorPos.Y < 0) then
        self.cursorPos.Y = self.cursorBounds.Height
      end

      self:ResetBlink()

    elseif(Button(Buttons.Right)) then

      self.cursorPos.X = self.cursorPos.X + 1

      if(self.cursorPos.X > self.cursorBounds.Width) then
        self.cursorPos.X = 0
      end

      self:ResetBlink()
    
    elseif(Button(Buttons.Down)) then

      self.cursorPos.Y = self.cursorPos.Y + 1

      if(self.cursorPos.Y > self.cursorBounds.Height) then
        self.cursorPos.Y = 0
      end

      self:ResetBlink()
    
    elseif(Button(Buttons.Left)) then

      self.cursorPos.X = self.cursorPos.X - 1

      if(self.cursorPos.X < 0) then
        self.cursorPos.X = self.cursorBounds.Width
      end

      self:ResetBlink()
    
    elseif(Button(Buttons.Select)) then

      self.currentTile = Repeat(self.currentTile + 1, 20)

      -- Reset the alt tile
      self.altTile = false

    end


  end

  -- Always check for the button release independent of the timer
  if(Button(Buttons.B, InputState.Released)) then

    self.altTile = not self.altTile

  end

  self.blinkTime = self.blinkTime + timeDelta

  if(self.blinkTime > self.blinkDelay) then

    self.blinkTime = 0

    self.blink = not self.blink

  end

  -- Update all of the cursor and selection values

  self.cursorX = (((self.cursorPos.X  + self.cursorBounds.X)) * 8)
  self.cursorY = ((self.cursorPos.Y + self.cursorBounds.Y) * 8)
  self.tileId = self.currentTile + 1
  self.selectionX = (self.tileId - 1) * 8

  if(self.altTile) then
    self.tileId = self.tileId + 20
  end

  self.spriteId = MetaSprite("tile-picker").Sprites[self.tileId].Id

  if(Button(Buttons.A, InputState.Released)) then

    DrawRect(self.cursorX, self.cursorY, 8, 8, BackgroundColor())
    Tile(self.cursorPos.X  + self.cursorBounds.X, self.cursorPos.Y  + self.cursorBounds.Y, self.spriteId)

  end

end

function EditorScene:ResetBlink()
  self.blinkTime = 0
  self.blink = false
end


function EditorScene:Draw()

  -- Draw the cursor
  if(self.blink == true) then

    -- Mask off the background
    DrawRect(self.cursorX, self.cursorY, 8, 8, BackgroundColor(), DrawMode.Sprite)

    -- Draw the currently selected tile
    DrawSprite(self.spriteId, self.cursorX, self.cursorY, false, false, DrawMode.Sprite)

  else

    -- Draw the cursor border
    self.cursorCanvas:DrawPixels(self.cursorX + self.cursorOffset.X, self.cursorY + self.cursorOffset.Y, DrawMode.Sprite)
  
  end
  
  -- Draw selected tile background
  DrawRect(self.selectionX, Display().Y - 8, 8, 8, 3, DrawMode.Sprite)

  -- Draw selected tile
  DrawSprite(self.spriteId, self.selectionX, Display().Y - 8, false, false, DrawMode.Sprite)

end


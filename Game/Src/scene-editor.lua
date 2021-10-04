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
    spriteId = 0,
    startTimer = -1,
    startDelay = 1000,
    startCount = 2,
    startCounts = 2,
    selectLock = false,
    startLock = false
  }
  setmetatable(_editor, EditorScene) -- make Account handle lookup

  return _editor

end

function EditorScene:Reset()

  self.selectLock = Button(Buttons.Select, InputState.Down)
  self.startLock = Button(Buttons.Start, InputState.Down)

  self.startTimer = -1

  self.cursorCanvas:SetStroke(4, 1)
  self.cursorCanvas:DrawRectangle(0, 0, self.cursorCanvas.Width, self.cursorCanvas.Height)

  -- Create UI
  DrawRect(0, 0, Display().X, 7, 0)
  DrawRect(0, Display().Y - 8, Display().X, 8, 2)
  

  DrawText("PLAY       TILE       DRAW     FLIP    ", 3, -1, DrawMode.TilemapCache, "medium", 3, -4)
  DrawText("      STR        SEL        A        B", 3, -1, DrawMode.TilemapCache, "medium", 2, -4)
  DrawText("     [   ]      [   ]      [ ]      [ ]", 3, -1, DrawMode.TilemapCache, "medium", 1, -4)

  DrawMetaSprite("tile-picker", 0, 17, false, false, DrawMode.Tile)

  -- Rebuild tilemap
  self.tiles = {
    {00, 00}, -- Empty
    {01, 20}, -- Door
    {02, 21}, -- Player
    {03, 22}, -- Enemy
    {04, 04}, -- Platform Left
    {05, 28}, -- Platform Center
    {06, 06}, -- Platform Right
    {07, 07}, -- Platform
    {08, 28}, -- Platform Edge (Should remove?)
    {09, 29}, -- Spike
    {10, 30}, -- Arrow Up
    {11, 31}, -- Arrow Right
    {12, 32}, -- Wall
    {13, 33}, -- Switch
    {14, 14}, -- Ladder
    {15, 15}, -- Key
    {16, 16}, -- GEM
    {17, 17}, -- Pillar Bottom
    {18, 18}, -- Pillar Middle
    {19, 19}, -- Pillar Top
  }

end

function EditorScene:Update(timeDelta)

  -- Reset select
  if(Button(Buttons.Select, InputState.Released)) then
    self.selectLock = false
  end

  -- Reset start
  if(Button(Buttons.Start, InputState.Released)) then
    self.startLock = false
  end

  -- Increment input time
  self.inputTime = self.inputTime + timeDelta

  -- Check for input delay
  if(self.inputTime > self.inputDelay) then
    
    -- Reset input time
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
    
    elseif(Button(Buttons.Select) and self.selectLock == false) then

      self.currentTile = Repeat(self.currentTile + 1, 20)

      -- Reset the alt tile
      self.altTile = false

    elseif(Button(Buttons.A)) then

      local value = self.spriteId > 1 and self.spriteId or -1

      if (Tile(self.cursorPos.X  + self.cursorBounds.X, self.cursorPos.Y  + self.cursorBounds.Y).SpriteId ~= value) then
        
        DrawRect(self.cursorX, self.cursorY, 8, 8, BackgroundColor())
        Tile(self.cursorPos.X + self.cursorBounds.X, self.cursorPos.Y + self.cursorBounds.Y, value)

        self:ResetBlink()

      end

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


  self.spriteId = self.tiles[self.currentTile + 1][self.altTile == false and 1 or 2]

  -- self.tileId = tiles[1]
  
  -- self.selectionX = (self.tileId - 1) * 8

  -- if(self.altTile and #tiles > 1) then
  --   self.tileId = tiles[2]
  -- end

  -- self.spriteId = self.tileId

  -- if(self.altTile) then
  --   self.tileId = self.tileId + 20
  -- end

  -- self.spriteId = MetaSprite("tile-picker").Sprites[self.tileId].Id

  

  if((Button(Buttons.Start, InputState.Down) and self.startLock == false) ) then


    self.startTimer = self.startTimer + timeDelta

    if(self.startTimer > self.startDelay) then

      self.startTimer = 0
      
      if(self.startCount > 0) then
        
        self.startCount = self.startCount - 1

      else
        
        -- Reset
        self.startTimer = 0
        self.startCount = self.startCounts


        -- TODO clear data if we are going back to load screen and go to the loader instead of the splash screen
         -- Switch to play scene
         SwitchScene(Button(Buttons.Select) and LOADER or RUN)

      end

    end
    
  elseif(Button(Buttons.Start, InputState.Released) or Button(Buttons.Select, InputState.Released)) then

    -- Reset
    self.startTimer = -1
    self.startCount = self.startCounts

    self.startLock = false

  end

end

function EditorScene:ResetBlink()
  self.blinkTime = 0
  self.blink = false
end


function EditorScene:Draw()

  if(self.startTimer > -1) then
    
    DrawRect(0, 0, Display().X, 7, 0, DrawMode.Sprite)
    DrawText((Button(Buttons.Select) and "QUIT" or "START") .. " GAME IN " .. self.startCount + 1, 52, -1, DrawMode.SpriteAbove, "medium", 3, -4)

  else

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

end

function EditorScene:SaveState()
  
  return "GameScene State"

end

function EditorScene:RestoreState(value)
  
  print("Restore state", state)

end


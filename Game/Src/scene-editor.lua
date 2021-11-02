--[[
  ## Space Station 8 `scene-editor.lua`

  
  
  Learn more about making Pixel Vision 8 games at http://docs.pixelvision8.com
]]--

-- We need to create a table to store all of the scene's functions.
EditorScene = {}
EditorScene.__index = EditorScene

MOUSE_TIMER = "MouseTimer"
BLINK_TIMER = "BlinkTimer"
INPUT_LOCK_TIMER = "InputLockTimer"
INPUT_TIMER = "InputTimer"

MODE_DRAW, MODE_OPTIONS, MODE_RENAME = 1, 2, 3

function EditorScene:Init()

  local _editor = {
    cursorPos = NewPoint(0, 0),
    cursorBounds = NewRect(0, 1, (Display().C) - 1, (Display().R) - 3),
    currentTile = 0,
    cursorCanvas = NewCanvas(8, 8),
    
    blink = false,
    altTile = false,
    tileId = 0,
    selectionX = 0,
    spriteId = 0,

    lastMousePos = NewPoint(),
    hideCursor = true,
    blinkTime = 500,
    
    mouseTime = -1,
    mode = MODE_DRAW,
  }
  
  
  NewTimer(INPUT_TIMER, 100)

  _editor.tiles = {
    {00, 00}, -- Empty
    {01, 20}, -- Door
    {02, 21}, -- Player
    {03, 22}, -- Enemy
    {04, 04}, -- Platform Left
    {05, 05}, -- Platform Center
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

  setmetatable(_editor, EditorScene) -- make Account handle lookup

  return _editor

end

function EditorScene:Reset()

  self.mode = MODE_DRAW

  -- self.selectLock = Button(Buttons.Select, InputState.Down)
  -- self.startLock = Button(Buttons.Start, InputState.Down)
  self.currentTile = 0
  self.startTimer = -1

  self.cursorPos.X = math.floor((Display().X * .5) / 8)
  self.cursorPos.Y = math.floor((Display().Y * .5) / 8) - 2

  self.cursorCanvas:SetStroke(4, 1)
  self.cursorCanvas:DrawRectangle(0, 0, self.cursorCanvas.Width, self.cursorCanvas.Height)

  -- Create UI
  DrawRect(0, 0, Display().X, 7, 0)
  DrawRect(0, Display().Y - 8, Display().X, 8, 2)


  local title = MessageBuilder
  (
    {
      {"TILE", 3},
      {"(", 1},
      {GetButtonMapping(Buttons.Select), 2},
      {") ", 1},
      {"DRAW", 3},
      {"(", 1},
      {GetButtonMapping(Buttons.A), 2},
      {") ", 1},
      {"FLIP", 3},
      {"(", 1},
      {GetButtonMapping(Buttons.B), 2},
      {") ", 1},
      {"OPTIONS", 3},
      {"(", 1},
      {GetButtonMapping(Buttons.Start), 2},
      {")", 1},
    }
  )

  DisplayTitle(title, -1)

  DrawMetaSprite("tile-picker", 0, 17, false, false, DrawMode.Tile)

  NewTimer(INPUT_LOCK_TIMER, 100)

  self.ready = false

  self:ResetBlink()

end

function EditorScene:Update(timeDelta)

  -- The first thing we want to do is check to see if the editor is ready to accept input. We do this by testing if `ready` is false and if the input lock timer has been triggered.
  if(self.ready == false) then
      
    if(TimerTriggered(INPUT_LOCK_TIMER) == true) then
      -- With the timer being triggered we can now make the tool ready to accept input.
      self.ready = true

      -- We no longer need the input lock timer so we can clear it.
      ClearTimer(INPUT_LOCK_TIMER)
    
    else

      -- The editor is no ready to accept input so we exit out of the `Update()` function.
      return

    end
  
  end

  -- In order to quit out of the editor, we need 
  if(Button(Buttons.Start, InputState.Released)) then

    self:OpenOptionMenu()
  
  end

  self:UpdateOptionMenu()

  -- Check for input delay
  if(TimerTriggered(INPUT_TIMER)) then
    
    -- Reset input time
    -- self.inputTime = 0

    if(Button(Buttons.Up)) then

      self.cursorPos.Y = self.cursorPos.Y - 1

      if(self.cursorPos.Y < self.cursorBounds.Top) then
        self.cursorPos.Y = self.cursorBounds.Bottom
      end

      self:ResetBlink()
    
    elseif(Button(Buttons.Down)) then

      self.cursorPos.Y = self.cursorPos.Y + 1

      if(self.cursorPos.Y > self.cursorBounds.Bottom) then
        self.cursorPos.Y = self.cursorBounds.Top
      end

      self:ResetBlink()

    end

    if(Button(Buttons.Right)) then

      self.cursorPos.X = self.cursorPos.X + 1

      if(self.cursorPos.X > self.cursorBounds.Right) then
        self.cursorPos.X = self.cursorBounds.Left
      end

      self:ResetBlink()
    
    elseif(Button(Buttons.Left)) then

      self.cursorPos.X = self.cursorPos.X - 1

      if(self.cursorPos.X < self.cursorBounds.Left) then
        self.cursorPos.X = self.cursorBounds.Right
      end

      self:ResetBlink()
    
    elseif(Button(Buttons.Select) and self.selectLock == false) then

      self.currentTile = Repeat(self.currentTile + 1, 20)

      -- Reset the alt tile
      self.altTile = false

    end

  end
  
  -- Always check for the button release independent of the timer
  if(Button(Buttons.B, InputState.Released) or MouseButton(1, InputState.Released)) then

    self.altTile = not self.altTile

  end

  self:UpdateMouse()

  self:UpdateCursor()
  
  


end

function EditorScene:UpdateCursor()

  if(self.mode ~= MODE_DRAW) then
    return
  end 


  if(TimerTriggered(BLINK_TIMER) == true) then

    self.blink = not self.blink

  end

  -- Make sure the cursor is in the bounds
  self.cursorPos.X = Clamp(self.cursorPos.X, self.cursorBounds.Left, self.cursorBounds.Right)
  self.cursorPos.Y = Clamp(self.cursorPos.Y, self.cursorBounds.Top, self.cursorBounds.Bottom)

  self.tileId = self.currentTile + 1
  self.selectionX = (self.tileId - 1) * 8

  self.spriteId = self.tiles[self.currentTile + 1][self.altTile == false and 1 or 2]


end

function EditorScene:UpdateMouse()

  if(self.mode ~= MODE_DRAW) then
    return
  end

  -- Update all of the cursor and selection values
  if(TimerTriggered(MOUSE_TIMER) == true) then
    
    ClearTimer(MOUSE_TIMER)
    self.showMouse = false

  end

  -- We need to capture the mouse's position on this frame incase we need to display the cursor.
  local newMousePos = MousePosition()
  
  -- We need to reset the mouse timer if we detect a change from the last `X` or `Y` position.
  if(self.lastMousePos.X ~= newMousePos.X or self.lastMousePos.Y ~= newMousePos.Y) then

    -- Here we are going to save the current mouse position so we have a reference of it in the next frame.
    self.lastMousePos = newMousePos

    -- Since we have detected a change in the mouse's movement, we need to reset the timer.
    -- self.mouseTime = 1000

    -- We can reset the timer by calling the `NewTimer()` API. We pass in the `MOUSE_TIMER` string as the timer name and the `1000` as the time in milliseconds.
    NewTimer(MOUSE_TIMER, 1000)

    self.showMouse = true

    -- It's important to note that Pixel Vision 8 pools timers. If a timer with the same name already exists, it's delay value will simply be updated and the timer will be reset. This is helpful to avoid creating lots of timers but can be problematic if you have different conditions looking at the same timer.

  end

if(self.showMouse == true) then
  -- self.mouseTime = self.mouseTime - (1000 * (timeDelta/1000))

  self.cursorPos.X = math.floor((self.lastMousePos.X) / 8)
  self.cursorPos.Y = math.floor((self.lastMousePos.Y) / 8)

end

if(self.lastMousePos.Y > (Display().Y - 8)) then

  self.hideCursor = true

  if(MouseButton(0, InputState.Released)) then

    self.currentTile = self.cursorPos.X
  end

elseif(self.cursorPos.Y <= self.cursorBounds.Bottom) then

  self.hideCursor = false

  if((Button(Buttons.A) or MouseButton(0))) then

      local value = self.spriteId > 0 and self.spriteId or -1

    if (Tile(self.cursorPos.X, self.cursorPos.Y).SpriteId ~= value) then
      
      Tile(self.cursorPos.X, self.cursorPos.Y, value)

      self:ResetBlink()

    end
    
  end

end

end

function EditorScene:ResetBlink()
  NewTimer(BLINK_TIMER, self.blinkTime)
end


function EditorScene:Draw()

  if(self.mode ~= MODE_DRAW) then

    return

  end

  if(TimerValue(MOUSE_TIMER) > 0) then

    DrawMetaSprite("cursor", self.lastMousePos.X, self.lastMousePos.Y, false, false, DrawMode.Mouse)

  end

  if(self.hideCursor == false) then

    local cursorX = self.cursorPos.X * 8
    local cursorY = self.cursorPos.Y * 8

    -- Draw the cursor
    if(self.blink == true) then

      -- Mask off the background
      DrawRect(cursorX, cursorY, 8, 8, BackgroundColor(), DrawMode.Sprite)

      -- Draw the currently selected tile
      DrawSprite(self.spriteId, cursorX, cursorY, false, false, DrawMode.Sprite)

    end

    self.cursorCanvas:DrawPixels(cursorX, cursorY, DrawMode.Sprite)
  
  else

    DrawRect(self.cursorPos.X * 8, Display().Y - 9, 8, 1, 3, DrawMode.UI)
  
  end
  
  -- Draw selected tile background

  DrawRect(self.selectionX, Display().Y - 9, 8, 9, 3, DrawMode.Sprite)

  -- Draw selected tile
  DrawSprite(self.spriteId, self.selectionX, Display().Y - 8, false, false, DrawMode.Sprite)

  -- end

end

function EditorScene:OpenOptionMenu()
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

  self.optionsOpen = true

  self.mode = MODE_OPTIONS
end

function EditorScene:CloseOptionMenu()

end

function EditorScene:UpdateOptionMenu()

  if(self.mode ~= MODE_OPTIONS) then
    return
  end

  if(Button(Buttons.A, InputState.Released)) then
      
    SwitchScene(RUN)

  elseif(Button(Buttons.B, InputState.Released)) then
    
    -- self.optionsOpen = false

    self:CloseOptionMenu()

  elseif(Button(Buttons.Select, InputState.Released)) then
    
    if(Button(Buttons.Start, InputState.Released)) then
      SwitchScene(SPLASH)
    else
      self.rename = true

      self:CloseOptionMenu()
    end

  end

end

function EditorScene:OpenRenameMenu()

end

function EditorScene:CloseRenameMenu()

end

function EditorScene:UpdateRenameMenu()

end
--[[
    ## Space Station 8 `scene-game.lua`

    Learn more about making Pixel Vision 8 games at http://docs.pixelvision8.com
]]--

-- The game scene needs to load a few dependent scripts first.
LoadScript("micro-platformer")
LoadScript("entities")
LoadScript("entity-player")
LoadScript("entity-enemy")

-- We need to create a table to store all of the scene's functions.
GameScene = {}
GameScene.__index = GameScene

-- This create a new instance of the game scene
function GameScene:Init()

  -- These should use a timer instead
  QUIT_TIMER, RESPAWN_TIMER, GAME_OVER_TIMER, WIN_GAME = 2, 1, 4, 4

  -- Now we can define some constants that respresent the points of specific items or actives in the game.
  STEP_POINT, KEY_POINT, GEM_POINT, EXIT_POINT = 10, 50, 100, 500

  EMPTY, SOLID, PLATFORM, DOOR_OPEN, DOOR_LOCKED, ENEMY, SPIKE, SWITCH_OFF, SWITCH_ON, LADDER, PLAYER, KEY, GEM = -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11


  -- 
  local _game = {
    
    totalInstances = 0,
    maxAir = 100,
    air = 100,
    airLoss = 4,
		maxLives = 3,
    flagMap = {},
    microPlatformer = MicroPlatformer:Init(),

    -- TODO Replace with timer
    startTimer = -1,
    startDelay = 1000,

  }

  setmetatable(_game, GameScene) -- make Account handle lookup

  _game:RegisterFlags()


  return _game

end

-- Since we manually loaded up the tilemap and are not using a tilemap flag file we need to register the flags manually. We'll do this by creating a list of meta sprites and the flags that should be associate with each of their sprites.
function GameScene:RegisterFlags()
  
  -- First, we need to build a lookup table for all of the flags. We'll do this by getting the meta sprite's children sprites and associating them with a particular flag. We'll create a nested table that contains arrays. Each array will have an array of sprite ids and a flag id. The final items in the table will be structured as `{sprites, flag}` so when we loop through this later, we can access the sprite array at position `1` and the associated flag at index `2`.
  local spriteMap = {
    {"solid", SOLID},
    {"platform", PLATFORM},
    {"door-open", DOOR_OPEN},
    {"door-locked", DOOR_LOCKED},
    {"enemy", ENEMY},
    {"spike", SPIKE},
    {"switch-off", SWITCH_OFF},
    {"switch-on", SWITCH_ON},
    {"ladder", LADDER},
    {"player", PLAYER},
    {"key", KEY},
    {"gem", GEM},
  }

  -- Now we can loop through the sprite names and create a flag lookup table for each of the sprites.
  for i = 1, #spriteMap do

    -- Since we know that each nested array looks like `{sprites, flag}` we can access the sprite array at position `1` and the associated flag at index `2`. Setting these two variables at the top of the loop just makes it easier to access them.
    local spriteName = spriteMap[i][1]
    local flag = spriteMap[i][2]
    
    -- Now we need to get all the sprites associated with the meta sprite's name by calling the `MetaSprite()` API.
    local sprites = MetaSprite(spriteName).Sprites

    -- Calling the `MetaSprite()` API returns a sprite collection. There are several properties and functions that can be called on the sprite collection. The most important one is the `Sprites` property which returns an array of all the sprites in the collection. Each item in the array is a `SpriteData` object which has an `Id` property we can use to determine which sprite in the collection should be associated with the flag.

    -- We'll loop through the flags and create a new array for each flag.
    for j = 1, #sprites do

      self.flagMap[sprites[j].Id] = flag
      
    end

  end

end

function GameScene:Reset()



  self.title = "PLAYING " .. string.upper(lastImagePath.EntityName:gsub(".spacestation8.png", ""))

  self.lives = self.maxLives

  self:RestartLevel()

end

function GameScene:RestartLevel()
  
  self.microPlatformer:Reset()

  -- Reset everything to default values
  self.atDoor = false
  self.startTimer = -1
  self.air = self.maxAir + 10
  
  -- Reset the score
  self.score = 0
  self.scoreDisplay = -1

  -- Reset the key flag
  self.unlockExit = false
  
  -- Create UI
  -- DrawRect(0, 0, Display().X, 7, 0)
  DrawRect(0, Display().Y - 8, Display().X, 8, 2)

  -- Clear old instances
  -- self.instances = {}
  -- self.totalInstances = 0
  self.originalSprites = {}

  local total = TilemapSize().C * (TilemapSize().R - 2)

  -- We need to keep track of some flag while we iterate over all of the tiles in the map. These flags will keep track of the three main things each level needs, a player, a key, and a door.
  local foundPlayer = false
  local foundDoor = false
  local foundKey = false

  -- If we don't fine all of these the map can not be played. So we need to make sure we have all of them after we are done looping through the tiles and kick the player back to the previous screen so the game doesn't throw an error.

  -- Loop through all of the tiles
  for i = 1, total do

    local pos = CalculatePosition(i-1, TilemapSize().C)
    
    local tile = Tile(pos.X, pos.Y)

    local spriteId = tile.SpriteId--tilemapData.SpriteIds.Pixels[i]

    -- Save the sprite Id so we can restore it before going back to the editor
    table.insert(self.originalSprites, spriteId)

    local flag = -1

    -- See if the sprite is mapped to a tile
    if(self.flagMap[spriteId] ~= nil) then

      -- Set the flag on the tile
      flag = self.flagMap[spriteId]

      -- Convert the x and y to pixels
      local x = pos.X * 8
      local y = pos.Y * 8

      -- solid
      if(flag == SOLID) then
      
      -- falling-platform
      elseif(flag == PLATFORM ) then
        
      -- door-open or door-locked
      elseif(flag == DOOR_OPEN or flag == DOOR_LOCKED) then
        
        if(foundDoor == false) then
          
          foundDoor = true

          -- Change the door to locked
          spriteId = MetaSprite("door-locked").Sprites[1].Id
          
          -- Lock the door
          flag = DOOR_LOCKED

          -- Save the door tile to unlock when the key is found
          self.doorTile = NewPoint(x, y)

        else

          -- Remove any other door sprite from the map
          spriteId = -1
          
        end

      -- enemy
      elseif(flag == ENEMY ) then
        
        local flip = Tile(pos.X, pos.Y).SpriteId ~= MetaSprite("enemy").Sprites[1].Id
      
        self.microPlatformer:AddEntity(Enemy:Init(x, y, flip))
        
        -- Remove any enemy sprites from the map
        spriteId = -1
        flag = -1

      -- player
      elseif(flag == PLAYER ) then
        
        if(foundPlayer == false) then

          local flip = Tile(pos.X, pos.Y).SpriteId ~= MetaSprite("player").Sprites[1].Id

          self.playerEntity = Player:Init(x, y, flip)

          self.microPlatformer:AddEntity(self.playerEntity)

          foundPlayer = true

          self.invalidateLives = true
        end

        -- Remove any player sprites from the map
        spriteId = -1
        flag = -1

      -- key
      elseif(flag == KEY ) then

        self.invalidateKey = true

        foundKey = true

      end
      
    end

    Tile(pos.X, pos.Y, spriteId, 0, flag)

  end


  if(foundPlayer == false or foundDoor == false or foundKey == false) then

    self:ReturnToEditor()

    return

  end
  
  -- DrawRect(0, Display().Y - 9, Display().X, 9, 0)


  DrawMetaSprite("top-bar", 0, 0, false, false, DrawMode.TilemapCache)
  DrawMetaSprite("bottom-hud", 0, Display().Y - 8, false, false, DrawMode.TilemapCache)
  DrawMetaSprite("ui-o2-border", 8 * 8, Display().Y - 8, false, false, DrawMode.TilemapCache)
  DrawMetaSprite("ui-o2-border", (8+4) * 8, Display().Y - 8, true, false, DrawMode.TilemapCache)

  DrawText("SCORE", 14*8, Display().Y - 9, DrawMode.TilemapCache, "medium", 2, -4)

  DisplayMessage(self.title, -1)

end

function GameScene:Update(timeDelta)

  local td = timeDelta/1000

  if(Button(Buttons.Select, InputState.Down) and self.startTimer == -1) then

    self.startTimer = 0
    self.startCount = QUIT_TIMER
    
  elseif(Button(Buttons.Select, InputState.Released)) then

    -- Reset
    self.startTimer = -1
    -- self.startCount = QUIT_TIMER

  end

  if(self.startTimer ~= -1) then
    
    self.startTimer = self.startTimer + timeDelta

    if(self.startTimer > self.startDelay) then

      self.startTimer = 0
      
      if(self.startCount > 0) then
        
        self.startCount = self.startCount - 1

      else

        if(Button(Buttons.Select, InputState.Down) == true or self.lives < 0 or self.atDoor == true) then
        
          self:ReturnToEditor()
        
        else
          
          self:RestoreTilemap()
          self:RestartLevel()
          self.startTimer = -1

        end

      end

    end
  end


  -- local starCount = stars

  local wasAlive = self.playerEntity.alive

  -- Update the player logic first so we always have the correct player x and y pos
  self.microPlatformer:Update(td)


  -- Check for collisions
  if(self.playerEntity.keyCollected and self.unlockExit == false) then

		self.unlockExit = true

    self.invalidateKey = true
    
    -- Clear the tile the player is currently in
    self:ClearTileAt(self.playerEntity.center)

    self:ClearTileAt(self.doorTile, MetaSprite("door-open").Sprites[1].Id, DOOR_OPEN)

    self:IncreaseScore(KEY_POINT)

	elseif(self.playerEntity.collectedGem == true) then

    self:IncreaseScore(GEM_POINT)

    self.playerEntity.collectedGem = false

    self:ClearTileAt(self.playerEntity.center)


	elseif(self.playerEntity.currentFlag == DOOR_OPEN and self.atDoor == false) then
		
		self.atDoor = true

    -- TODO exit level

    self.startTimer = 0
    self.startCount = WIN_GAME

    self:IncreaseScore(EXIT_POINT)

  end

  if(self.atDoor == false and self.playerEntity.alive == true) then

    self.air = self.air - (self.airLoss * td)

    if(self.air <= 0) then
      self.playerEntity.alive = false
    end

  end

  if(self.playerEntity.alive == false) then
    
    if(wasAlive == true) then

      self.startTimer = 0
      -- self.startCount = self.startCounts

      self.lives = self.lives - 1
      self.invalidateLives = true

      if(self.lives >= 0) then
        self.startCount = RESPAWN_TIMER
      else
        self.startCount = GAME_OVER_TIMER
      end

    end
 
  elseif(self.atDoor == false) then

    self:IncreaseScore(STEP_POINT * td)
  
  end

  local percent = (self.air/ self.maxAir)

  if(percent > 1) then
    percent = 1
  elseif(percent < 0) then
    percent = 0
  end

  DrawRect((8 * 8) + 2, Display().Y - 6, 36 * percent, 3, BackgroundColor(), DrawMode.Sprite)

  -- Update score
  if(self.scoreDisplay ~= self.score) then

    local diff = math.floor((self.score - self.scoreDisplay) / 4)

    if(diff < 5) then

      self.scoreDisplay = self.score

    else

      self.scoreDisplay = self.scoreDisplay + diff

    end

  end

  DrawText(string.padLeft(tostring(Clamp(self.scoreDisplay, 0, 9999)), 4, "0"), Display().X - (6 * 4), Display().Y - 9, DrawMode.SpriteAbove, "medium", 3, -4)


end


-- We can use this function to help making clearing tiles in the map easier. This is called when the player collects the key, gem, or the door is unlocked. It requires a position and an option new sprite id. By default, if no sprite id is provided, the tile will simply be cleared.
function GameScene:ClearTileAt(pos, newId, newFlag)

  newId = newId or -1
  newFlag = newFlag or -1

  local col = math.floor(pos.X/8)
  local row = math.floor(pos.Y/8)

  Tile(col, row, newId, 0, newFlag)

end

function GameScene:Draw()

  if(self.startTimer > -1) then
    
    local message = "IN " .. self.startCount + 1

    if(Button(Buttons.Select, InputState.Down) == true) then

      message = "EXITING GAME " .. message

    elseif(self.lives < 0) then

      message = "GAME OVER " .. message
    
    elseif(self.atDoor == true) then

      message = "ESCAPING " .. message

    else

      message = "RESTARTING " .. message

    end

    DisplayMessage(message, -1, 1)

  else

    -- TODO this is being called on every draw frame

    DisplayMessage(self.title, -1, true)
  
  end

  if(self.invalidateLives == true) then
    
    for i = 1, self.maxLives do
      DrawMetaSprite("ui-life", i * 8, Display().Y - 9, true, false, DrawMode.TilemapCache, self.lives < i and 1 or 3)
    end

    self.invalidateLives = false

  end
  
  if(self.invalidateKey == true) then
    DrawMetaSprite("ui-key", 40, Display().Y - 8, false, false, DrawMode.TilemapCache, self.unlockExit == true and 2 or 1)
    self.invalidateKey = false
  end

  if(self.atDoor == false) then

    -- Need to draw the player last since the order of sprite draw calls matters
    self.microPlatformer:Draw()
  
  end

end

function GameScene:RestoreTilemap()

  local total = #self.originalSprites
  
  for i = 1, total do
    
    local pos = CalculatePosition(i-1, TilemapSize().C)

    Tile(pos.X, pos.Y, self.originalSprites[i], 0, -1)

  end

end

function GameScene:ReturnToEditor()
  
  self:RestoreTilemap()
  SwitchScene(EDITOR)

end

function GameScene:IncreaseScore(value)

  self.score = self.score + value

end
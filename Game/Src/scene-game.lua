--[[
    ## Space Station 8 `scene-game.lua`

    Learn more about making Pixel Vision 8 games at http://docs.pixelvision8.com
]]--

LoadScript("micro-platformer")
LoadScript("entities")
LoadScript("entity-player")
LoadScript("entity-enemy")

-- Splash Scene
GameScene = {}
GameScene.__index = GameScene

function GameScene:Init()

  QUIT_TIMER, RESPAWN_TIMER, GAME_OVER_TIMER, WIN_GAME = 2, 1, 4, 4

  STEP_POINT, KEY_POINT, GEM_POINT, EXIT_POINT = 10, 50, 100, 500

  local _game = {
    totalInstances = 0,
    bounds = Display(),
    scoreDisplay = 0,
    startTimer = -1,
    startDelay = 1000,
    score = 0,
    maxAir = 100,
    air = 100,
    airLoss = 4,
		maxLives = 3,
		lives = 3,
    atDoor = false,
    microPlatformer = MicroPlatformer:Init()

  }
  setmetatable(_game, GameScene) -- make Account handle lookup

  return _game

end

function GameScene:Reset()
  
  self.lives = self.maxLives

  self:RestartLevel()
end

function GameScene:RestartLevel()
  
  self.microPlatformer:Reset()

  -- Reset everything to default values
  self.atDoor = false
  self.startTimer = -1
  self.air = self.maxAir + 10
  self.score = 0
  self.scoreDisplay = -1

  -- Reset the key flag
  self.hasKey = false
  

  -- Create UI
  -- DrawRect(0, 0, Display().X, 7, 0)
  DrawRect(0, Display().Y - 8, Display().X, 8, 2)

  -- Clear old instances
  -- self.instances = {}
  -- self.totalInstances = 0
  self.originalSprites = {}

  local flagMap = {}

  EMPTY, SOLID, PLATFORM, DOOR_OPEN, DOOR_LOCKED, ENEMY, SPIKE, SWITCH_OFF, SWITCH_ON, LADDER, PLAYER, KEY, GEM = -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11

  -- Find all the sources for each flag {Sprites, FlagId}
  local spriteSrc = {

    {MetaSprite("solid").Sprites, SOLID},
    {MetaSprite("platform").Sprites, PLATFORM},
    {MetaSprite("door-open").Sprites, DOOR_OPEN},
    {MetaSprite("door-locked").Sprites, DOOR_LOCKED},
    {MetaSprite("enemy").Sprites, ENEMY},
    {MetaSprite("spike").Sprites, SPIKE},
    {MetaSprite("switch-off").Sprites, SWITCH_OFF},
    {MetaSprite("switch-on").Sprites, SWITCH_ON},
    {MetaSprite("ladder").Sprites, LADDER},
    {MetaSprite("player").Sprites, PLAYER},
    {MetaSprite("key").Sprites, KEY},
    {MetaSprite("gem").Sprites, GEM}
    
  }

  -- Loop through all of the sprite sources
  for i = 1, #spriteSrc do
    
    -- Save the sprites and flag reference
    local sprites = spriteSrc[i][1]
    local flag = spriteSrc[i][2]
    
    -- Loop through all of the sprites
    for j = 1, #sprites do

      -- Map the sprite id to the flag
      flagMap[sprites[j].Id] = flag
      
    end

  end

  local total = TilemapSize().X * (TilemapSize().Y - 2)

  local foundPlayer = false
  local foundDoor = false
  local foundKey = false

  -- Loop through all of the tiles
  for i = 1, total do

    local pos = CalculatePosition(i-1, TilemapSize().X)
    
    local tile = Tile(pos.X, pos.Y)

    local entity = nil

    -- print("tile", pos, tile.SpriteId)

    local spriteId = tile.SpriteId--tilemapData.SpriteIds.Pixels[i]

    -- Save the sprite Id so we can restore it before going back to the editor
    table.insert(self.originalSprites, spriteId)

    local flag = -1

    -- See if the sprite is mapped to a tile
    if(flagMap[spriteId] ~= nil) then

      -- Set the flag on the tile
      flag = flagMap[spriteId]

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
      
        entity = Enemy:Init(x, y, flip)
        
        -- Remove any enemy sprites from the map
        spriteId = -1
        flag = -1

      -- player
      elseif(flag == PLAYER ) then
        
        if(foundPlayer == false) then

          self.playerEntity = Player:Init(0, 0)

          self.playerEntity.jumpSound = -1
          self.playerEntity.hitSound = -1

          -- TODO should be built in
          self.playerEntity.hitRect = NewRect(0, 0, 8, 8)
          self.playerEntity.spriteID = 1

          -- TODO remove timer
          self.playerEntity.time = 0
          self.playerEntity.delay = .1

          -- TODO remap these to the entity and the key to the level
          self.playerEntity.spriteOffset = 0
          self.playerEntity.alive = true
          self.playerEntity.hasKey = false

          self.microPlatformer:AddEntity(self.playerEntity)

          self.playerPos = NewPoint(x, y)

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

      -- gem
      elseif(flag == GEM ) then

      end
      
    end

    Tile(pos.X, pos.Y, spriteId, 0, flag)

    if(entity ~= nil) then

      -- Add the instance to the list to render
      -- table.insert(self.instances, entity)

      self.microPlatformer:AddEntity(entity)

    end
    

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


  local message = string.sub(lastImagePath.EntityName, 0, - #" .spacestation8.png"):upper()
  local maxChars = 10
  if(#message > maxChars) then
    message = string.sub(message, 0, maxChars) .. "..."
  end

  DrawText("PLAYING " .. message, 8, -1, DrawMode.TilemapCache, "medium", 3, -4)
  DrawText("SPACE STATION 8", Display().X - 68, -1, DrawMode.TilemapCache, "medium", 3, -4)

  -- Update the total instance count
  -- self.totalInstances = #self.instances

  -- Reset the player
  self.playerEntity.x = self.playerPos.X
  self.playerEntity.y = self.playerPos.Y

  -- self.playerEntity.hitRect.X = self.playerPos.X
  -- self.playerEntity.hitRect.Y = self.playerPos.Y
  self.playerEntity.dx = 0
  self.playerEntity.dy = 0
  self.playerEntity.alive = true
  self.playerEntity.dir = false

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
  if(self.playerEntity.hasKey and self.hasKey == false) then

		self.hasKey = true

    -- self:ClearTileAt(self.playerEntity.hitRect, MetaSprite("door-open").Sprites[1].Id, DOOR_OPEN)

    self.invalidateKey = true
    
    -- DrawRect(self.doorTile.X * 8, self.doorTile.Y * 8, 8, 8, 3)
    -- Tile(self.doorTile.X, self.doorTile.Y, MetaSprite("door-open").Sprites[1].Id, 0, DOOR_OPEN)

    self:ClearTileAt(self.playerEntity.hitRect)

    self:ClearTileAt(self.doorTile, MetaSprite("door-open").Sprites[1].Id, DOOR_OPEN)

    self:IncreaseScore(KEY_POINT)

    -- print("KEY COLLISION")

	elseif(self.playerEntity.currentFlag == GEM) then

    print("GEM")
    self:IncreaseScore(GEM_POINT)

    self:ClearTileAt(self.playerEntity.hitRect)

		-- Tile(self.microPlatformer.currentFlagPos.X, self.microPlatformer.currentFlagPos.Y, -1, 0, -1)

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

  DrawRect((8 * 8) + 2, Display().Y - 6, 36 * percent, 3, 2, DrawMode.Sprite)

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

    DrawMetaSprite("top-bar", 0, 0, false, false, DrawMode.TilemapCache)

    local offset = (Display().X - (#message * 4)) * .5
    
    DrawText(message, offset, -1, DrawMode.SpriteAbove, "medium", 3, -4)

  end

  for i = 1, self.totalInstances do

    local entity = self.instances[i]

    if(entity.alive == true) then
      entity:Draw(0, 0)
    end

  end

  if(self.invalidateLives == true) then
    
    for i = 1, self.maxLives do
      DrawMetaSprite("ui-life", i * 8, Display().Y - 9, true, false, DrawMode.TilemapCache, self.lives < i and 1 or 3)
    end

    self.invalidateLives = false

  end
  
  if(self.invalidateKey == true) then
    DrawMetaSprite("ui-key", 40, Display().Y - 8, false, false, DrawMode.TilemapCache, self.hasKey == true and 2 or 1)
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
    
    local pos = CalculatePosition(i-1, TilemapSize().X)

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
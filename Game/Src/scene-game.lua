--[[
  Pixel Vision 8 - ReaperBoy v2
  Copyright (C) 2017, Pixel Vision 8 (http://pixelvision8.com)
  Created by Jesse Freeman (@jessefreeman)

  Licensed under the Microsoft Public License (MS-PL) License.

  Learn more about making Pixel Vision 8 games at http://pixelvision8.com
]]--

LoadScript("micro-platformer")
LoadScript("entities")

-- Splash Scene
GameScene = {}
GameScene.__index = GameScene

function GameScene:Init()

  QUIT_TIMER, RESPAWN_TIMER, GAME_OVER_TIMER, WIN_GAME = 2, 1, 4, 4

  local _game = {
    totalInstances = 0,
    bounds = Display(),
    scoreDisplay = 0,
    startTimer = -1,
    startDelay = 1000,
    -- startCount = 2,
    -- startCounts = 2,
    score = 0,
    -- time = 0,
    -- nextLevelDelay = 5,
    -- nextLevelTime = 0,
    -- nextLevel = false,
    -- unlockDoor = false,
		maxLives = 3,
		lives = 3,
    atDoor = false
  }
  setmetatable(_game, GameScene) -- make Account handle lookup

  -- _game.levelOffset = 2

  -- _game.bounds = Display();

  _game.microPlatformer = MicroPlatformer:Init()
  _game.microPlatformer.jumpSound = 4
  _game.microPlatformer.hitSound = 5

  -- Get a reference to the player entity
  _game.playerEntity = _game.microPlatformer.player

  return _game

end

function GameScene:RestartLevel()
  -- Reset the player
  self.playerEntity.hitRect.X = self.playerPos.x
  self.playerEntity.hitRect.Y = self.playerPos.y
  self.playerEntity.dx = 0
  self.playerEntity.dy = 0
  self.playerEntity.alive = true
  self.playerEntity.dir = false
  self.playerEntity.jumpvel = 2.5
  self.playerEntity.isgrounded = false
  
end

function GameScene:Reset()

  -- Reset everything to default values
  self.score = 0
  -- self.nextLevel = false
  -- self.unlockDoor = false
  -- self.nextLevelDelay = 500
  self.atDoor = false
  self.lives = self.maxLives
  self.startTimer = -1

  -- Set the player sprites
  self.playerEntity.sprites = MetaSprite("player").Sprites

  -- Reset the key flag
  self.hasKey = false

  -- Create UI
  -- DrawRect(0, 0, Display().X, 7, 0)
  DrawRect(0, Display().Y - 8, Display().X, 8, 2)

  -- Clear old instances
  self.instances = {}
  self.totalInstances = 0
  self.originalSprites = {}

  local flagMap = {}

  SOLID, PLATFORM, DOOR_OPEN, DOOR_LOCKED, ENEMY, SPIKE, SWITCH_OFF, SWITCH_ON, LADDER, PLAYER, KEY, GEM = 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11

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
          self.doorTile = NewPoint(pos.X, pos.Y)

        else

          -- Remove any other door sprite from the map
          spriteId = -1
          
        end

      -- enemy
      elseif(flag == ENEMY ) then
      
        print("Enemy", x, y)

        entity = Enemy:Init(x, y)
        -- totalStars = totalStars + 1

        -- Tile(pos.X, pos.Y, -1)

        -- Remove any enemy sprites from the map
        spriteId = -1

      -- spike
      elseif(flag == SPIKE ) then
      
      -- switch-off
      elseif(flag == SWITCH_OFF ) then
        
      -- switch-on
      elseif(flag == SWITCH_ON ) then
      
      -- ladder
      elseif(flag == LADDER ) then
        
      -- player
      elseif(flag == PLAYER ) then
        
        if(foundPlayer == false) then
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

          print("Found Gem")
      end
      
    end

    Tile(pos.X, pos.Y, spriteId, 0, flag)


    if(entity ~= nil) then

      -- Add the instance to the list to render
      table.insert(self.instances, entity)

    end
    

  end


  if(foundPlayer == false or foundDoor == false or foundKey == false) then

    -- TODO need to pass a message to the scene it was missing things
    SwitchScene(EDITOR)

  end
  
  DrawMetaSprite("top-bar", 0, 0, false, false, DrawMode.TilemapCache)
  DrawMetaSprite("bottom-hud", 0, Display().Y - 8, false, false, DrawMode.TilemapCache)
  DrawMetaSprite("ui-o2-border", 8 * 8, Display().Y - 8, false, false, DrawMode.TilemapCache)
  DrawMetaSprite("ui-o2-border", (8+4) * 8, Display().Y - 8, true, false, DrawMode.TilemapCache)

  DrawText("SCORE", 14*8, Display().Y - 9, DrawMode.TilemapCache, "medium", 2, -4)

  DrawText("SPACE STATION 8", 3, -1, DrawMode.TilemapCache, "medium", 3, -4)

  -- Update the total instance count
  self.totalInstances = #self.instances


  self:RestartLevel()

end

function GameScene:Update(timeDelta)

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
          
          self:RestartLevel()
          self.startTimer = -1

        end

      end

    end
  end


  -- local starCount = stars

  local wasAlive = self.playerEntity.alive

  -- Update the player logic first so we always have the correct player x and y pos
  self.microPlatformer:Update(timeDelta / 1000)


  -- Check for collisions
  if(self.microPlatformer.currentFlag == KEY) then

		self.hasKey = true
		
		Tile(self.microPlatformer.currentFlagPos.X, self.microPlatformer.currentFlagPos.Y, -1)

    self.invalidateKey = true
    
    -- DrawRect(self.doorTile.X * 8, self.doorTile.Y * 8, 8, 8, 3)
    Tile(self.doorTile.X, self.doorTile.Y, MetaSprite("door-open").Sprites[1].Id, 0, DOOR_OPEN)

	elseif(self.microPlatformer.currentFlag == GEM) then

    self.score = score + 100

		Tile(self.microPlatformer.currentFlagPos.X, self.microPlatformer.currentFlagPos.Y, -1)

	elseif(self.microPlatformer.currentFlag == DOOR_OPEN and self.atDoor == false) then
		
		print("LOCKED DOOR_OPEN")

		self.atDoor = true

    -- TODO exit level

    self.startTimer = 0
    self.startCount = WIN_GAME

  end

  self.playerEntity.hitRect.X = Repeat(self.playerEntity.hitRect.X, self.bounds.x-4)
  -- self.playerEntity.hitRect.Y = Repeat(self.playerEntity.hitRect.Y, self.bounds.y)

  -- Loop through all of the entities
  for i = 1, self.totalInstances do

    -- Get the current entity in the list
    local entity = self.instances[i]

    -- print("Update Entity", entity)

    -- Test to see if the entity is still alive
    if(entity.alive == true) then

      -- Test to see if the entity should be updated
      if(entity.Update ~= nil) then

        -- TODO calculate the next animation frame?
        self.instances[i]:Update(timeDelta)

      end

      -- Test to see if the entity should be updated
      if(entity.Collision ~= nil) then

        -- TODO calculate the next animation frame?
        self.instances[i]:Collision(self.playerEntity)

      end

    end

  end


  if(self.playerEntity.alive == false) then
    
    if(wasAlive == true) then

      -- Reset the timer
      -- self.time = 0

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

  end

  -- Update score
  if(self.scoreDisplay ~= self.score) then

    local diff = math.floor((self.score - self.scoreDisplay) / 4)

    -- print(score, self.scoreDisplay, diff)

    self.scoreDisplay = self.scoreDisplay + diff

    if(self.scoreDisplay < 0) then
      self.scoreDisplay = 0
    end

    -- Clear below
    DrawText(LeftPad(tostring(self.scoreDisplay), 5, "0"), Display().X - (6 * 4), Display().Y - 9, DrawMode.TilemapCache, "medium", 3, -4)

    -- DrawText(LeftPad(tostring(self.scoreDisplay), 6, "0"), 15 * 8, Display().Y - 9, DrawMode.TilemapCache, "medium" - 4)

  end

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

  else

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

  if(Button(Buttons.Start)) then

    local total = 20 * 18

    for i = 1, total do
      
      local pos = CalculatePosition(i-1, 20)

      DrawText(Flag(pos.X, pos.Y), pos.X * 8, pos.Y * 8, DrawMode.Sprite, "medium", 3, -5)

    end

  end

end

function GameScene:SaveState()
  
  return "GameScene State"

end

function GameScene:RestoreState(value)
  
  print("Restore state", state)

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
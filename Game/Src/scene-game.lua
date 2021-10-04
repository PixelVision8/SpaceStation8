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

  local _game = {
    totalInstances = 0,
    bounds = Display(),
    scoreDisplay = 0,
    startTimer = -1,
    startDelay = 1000,
    startCount = 2,
    startCounts = 2,
    score = 0
  }
  setmetatable(_game, GameScene) -- make Account handle lookup

  -- _game.levelOffset = 2

  -- _game.bounds = Display();

  _game.microPlatformer = MicroPlatformer:Init()
  _game.microPlatformer.jumpSound = 4
  _game.microPlatformer.hitSound = 5

  _game.playerEntity = _game.microPlatformer.player

  -- _game.playerEntity.spriteData = player


  -- _game.totalLevelTiles = levelSize.x * levelSize.y

  -- _game.exitSign = {x = 50, y = 50}
  -- _game.scoreDisplay = 0

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
  self.playerEntity.jumpvel = 3
  self.playerEntity.isgrounded = false

  self.microPlatformer.grav = 0.2
  self.loop = 0
  self.shakeX = 0
  self.shakeY = 0
  self.time = 0
  self.nextLevelDelay = 2
  self.nextLevel = false
  self.unlockDoor = false

  if(self.ghost ~= nil) then
    self.ghost.alive = false
  end

end

function GameScene:SpawnDust(x, y, loop)

  local dustEntity = nil

  for i = 1, #self.dust do

    if(self.dust[i].alive == false) then

      dustEntity = self.dust[i]

    end

  end

  if(dustEntity == nil) then

    dustEntity = Dust:Init(x, y)

    table.insert(self.instances, dustEntity)
    self.totalInstances = #self.instances

    table.insert(self.dust, dustEntity)

  end

  dustEntity.x = x
  dustEntity.y = y
  dustEntity.alive = true
  dustEntity.frame = 1
  dustEntity.loop = loop

end

function GameScene:SpawnStar(x, y)

  local starEntity = nil

  for i = 1, #self.stars do

    if(self.stars[i].alive == false) then

      starEntity = self.stars[i]

    end

  end

  if(starEntity == nil) then

    starEntity = Star:Init(x, y)

    table.insert(self.instances, starEntity)
    self.totalInstances = #self.instances

    table.insert(self.stars, starEntity)

  end

  starEntity.x = x
  starEntity.y = y
  starEntity.alive = true
  starEntity.lifeTime = 0

end

function GameScene:Reset()

  self.startTimer = -1

  self.microPlatformer.player.sprites = MetaSprite("player").Sprites

  -- Create UI
  -- DrawRect(0, 0, Display().X, 7, 0)
  DrawRect(0, Display().Y - 8, Display().X, 8, 2)

  
  

  DrawText("SPACE STATION 8", 3, -1, DrawMode.TilemapCache, "medium", 3, -4)

  -- ClearUILayer()

  -- Clear old instances
  self.instances = {}
  self.totalInstances = 0
  -- self.boss = nil
  -- self.dust = {}
  -- self.stars = {}
  -- self.bossBattle = false
  -- self.ghost = nil

  -- Default player position
  -- self.playerPos = NewPoint(4 * 8, TilemapSize().Y - 2 * 8)

  -- -- Reset global star counter

  -- stars = 0
  -- totalStars = 0


  -- Clear the exit position
  self.exitPos = nil


  self.originalSprites = {}



  local flagMap = {
    
  }

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
        end

        -- Remove any player sprites from the map
        spriteId = -1
        flag = -1

      -- key
      elseif(flag == KEY ) then
      
      -- gem
      elseif(flag == GEM ) then

      end
      
    end

    Tile(pos.X, pos.Y, spriteId, 0, flag)


    if(entity ~= nil) then

      -- Add the instance to the list to render
      table.insert(self.instances, entity)

    end
    

  end

  -- print("Test", MetaSprite("bottom-hud").Sprites[2].ColorOffset)
  
  -- MetaSprite("bottom-hud").Sprites[2].ColorOffset = 2

  DrawMetaSprite("top-bar", 0, 0, false, false, DrawMode.TilemapCache)
  DrawMetaSprite("bottom-hud", 0, Display().Y - 8, false, false, DrawMode.TilemapCache)
  DrawMetaSprite("ui-o2-border", 8 * 8, Display().Y - 8, false, false, DrawMode.TilemapCache)
  DrawMetaSprite("ui-o2-border", (8+4) * 8, Display().Y - 8, true, false, DrawMode.TilemapCache)


  local maxLives = 3
  local lives = 2
  local hasKey = true

  for i = 1, maxLives do
    DrawMetaSprite("ui-life", i * 8, Display().Y - 9, true, false, DrawMode.TilemapCache, lives < maxLives and 3 or 1)
  end

  DrawMetaSprite("ui-key", 40, Display().Y - 8, true, false, DrawMode.TilemapCache, hasKey and 2 or 0)

  DrawText("SCORE", 14*8, Display().Y - 9, DrawMode.TilemapCache, "medium", 2, -4)


  
  -- print("Test 2", MetaSprite("bottom-hud").Sprites[2].ColorOffset)
  -- -- GoToScreen(level + self.levelOffset)

  -- -- TODO for debugging
  -- level = 1

  -- -- LoadTilemap("tilemap-" .. level)
  

  -- -- Get the current scroll position
  -- local pos = ScrollPosition()

  -- -- Create a new vector for the scroll position
  -- self.scrollPos = NewPoint(pos.x, pos.y)

  -- -- Draw UI
  -- DrawMetaSprite("sky", 0, 0, false, false, DrawMode.TilemapCache)

  -- DrawMetaSprite("border-left", 0, 0, false, false, DrawMode.TilemapCache)
  -- DrawMetaSprite("border-top", 16, 0, false, false, DrawMode.TilemapCache)
  -- DrawMetaSprite("border-left", 160-16, 0, true, false, DrawMode.TilemapCache)

  -- -- Create two clouds
  -- for i = 1, 2 do

  --   local cloud = Cloud:Init(
  --     math.random(0, Display().X),
  --     math.random(7, Display().Y - 6),
  --     i < 2 and "cloud-small" or "cloud-large",
  --     math.random(5, 10)
  --   )

  --   -- Add the instance to the list to render
  --   table.insert(self.instances, cloud)

  -- end


  -- {MetaSprite("solid").Sprites, 0},
  -- {MetaSprite("falling-platform").Sprites, 1},
  -- {MetaSprite("door-open").Sprites, 3},
  -- {MetaSprite("door-locked").Sprites, 4},
  -- {MetaSprite("enemy").Sprites, 5},
  -- {MetaSprite("spike").Sprites, 6},
  -- {MetaSprite("switch-off").Sprites, 7},
  -- {MetaSprite("switch-on").Sprites, 8},
  -- {MetaSprite("ladder").Sprites, 9},
  -- {MetaSprite("player").Sprites, 10},
  -- {MetaSprite("key").Sprites, 11},
  -- {MetaSprite("gem").Sprites, 12}
  

  -- for i = 1, total do
    
  --   local pos = CalculatePosition(i-1, TilemapSize().X)

  --   local flag = Flag(pos.X, pos.Y)

  --   -- Convert the x and y to pixels
  --   local x = pos.X * 8
  --   local y = pos.Y * 8

  --   local entity = nil

    
  --   if(flag == 2) then -- Door

  --     if(self.exitPos == nil) then

  --       -- Save the first tile position
  --       self.exitPos = {
  --         c = realC,
  --         r = realR,
  --         x = x,
  --         y = y,
  --         w = 16,
  --         h = 16
  --       }

  --     end

  --     -- Make sure that the door tiles are displaying a locked door
  --     DrawMetaSprite("door-close", x, y, false, false, DrawMode.TilemapCache)
  --   --   UpdateTiles(self.exitPos.c, self.exitPos.r, doorlocked.width, doorlocked.spriteIDs)

    -- elseif(flag == 8) then -- Enemy
  --   --   -- TODO need to know what kind of enemy it is and how many stars its worth
  --     entity = Enemy:Init(x, y)
  --     totalStars = totalStars + 1

  --     Tile(pos.X, pos.Y, -1)

  --   elseif(flag == 9) then

  --   --   if(self.bossBattle ~= true) then

  --   --     -- TODO need to know what kind of enemy it is and how many stars its worth
  --   --     entity = Boss:Init(x, y)

  --   --     self.bossBattle = true
  --   --     self.boss = entity

  --   --     totalStars = totalStars + 4

  --   --   end

    -- elseif(flag == 13) then -- Player

  --   --   -- Reset the player
  --     self.playerPos.x = x
  --     self.playerPos.y = y
      

  --   --   print("FOUND PLAYER")

  --   end

  --   if(entity ~= nil) then

  --     -- Add the instance to the list to render
  --     table.insert(self.instances, entity)

    -- end

    self:RestartLevel()

  -- end

  -- -- Update the total instance count
  self.totalInstances = #self.instances

  -- -- Draw stars
  -- for i = 1, totalStars do

  --   self:DrawStar("star-off", i)

  -- end

  -- DrawText(LeftPad(tostring(score), 6, "0"), 32, 1, DrawMode.Tile, "default")

end

function GameScene:DrawStar(name, index)

  local star = MetaSprite(name)

  local tmpC = 2 + ((index - 1) * star.Width)
  
  DrawMetaSprite(star, (tmpC) * 8, 3, false, false, DrawMode.TilemapCache)

end

function GameScene:Update(timeDelta)


  if(Button(Buttons.Select, InputState.Down)) then


    self.startTimer = self.startTimer + timeDelta

    if(self.startTimer > self.startDelay) then

      self.startTimer = 0
      
      if(self.startCount > 0) then
        
        self.startCount = self.startCount - 1

      else

        -- Reset
        self.startTimer = 0
        self.startCount = self.startCounts

        self:RestoreTilemap()

        -- Switch to play scene
        SwitchScene(EDITOR)

      end

    end
    
  elseif(Button(Buttons.Select, InputState.Released)) then

    -- Reset
    self.startTimer = -1
    self.startCount = self.startCounts
  end


  -- local starCount = stars

  -- local wasAlive = self.playerEntity.alive

  -- -- Reset scroll position
  -- -- ScrollPosition(self.scrollPos.x, self.scrollPos.y)


  -- Update the player logic first so we always have the correct player x and y pos
  self.microPlatformer:Update(timeDelta / 1000)

  -- if(self.playerEntity.y > 144) then
  --   self.loop = self.loop + 1

  --   if(self.loop < 2)then
  --     PlaySound(11, 3)

  --   elseif(self.loop < 4) then
  --     PlaySound(12, 3)
  --   else
  --     PlaySound(13, 3)

  --   end

  --   if(self.loop > 5) then
  --     self.loop = 5
  --   end

  -- end

  -- -- If player hits the ground, apply bonus or kill them
  -- if(self.playerEntity.isgrounded == true) then

  --   if(self.loop > 0) then

  --     self.playerEntity.dy = -(self.playerEntity.jumpvel * (self.loop / 4))

  --     score = score - (20 * self.loop)

  --     if(score < 0) then
  --       score = 0
  --     end

  --     if(self.loop >= 5 and score <= 0) then
  --       self.playerEntity.alive = false
  --     end

  --     -- Reset loop counter
  --     self.loop = 0

  --     self:SpawnDust(self.playerEntity.x, self.playerEntity.y)

  --     PlaySound(7, 3)

  --   elseif(self.playerEntity.justKilled == true) then
  --     self.playerEntity.justKilled = false
  --   end

  -- end

  -- Wrap player's x and y position after the platform collision was calculated

  -- if(self.playerEntity.hitRect.X < -2) then
  --   self.playerEntity.hitRect.X = self.bounds.x - 2
  -- elseif(self.playerEntity.hitRect.X > self.bounds.x - 4) then
  --   self.playerEntity.hitRect.X = - 2
  -- end
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


  -- if(self.playerEntity.alive == false) then

  --   if(wasAlive == true) then

  --     local frames = {
  --       ghost1,
  --       ghost2
  --     }

  --     if(self.ghost == nil) then
  --       self.ghost = Ghost:Init(0, 0, frames, .4, 10)
  --       table.insert(self.instances, self.ghost)
  --       self.totalInstances = #self.instances
  --     end

  --     self.ghost.x = self.playerEntity.x - 8
  --     self.ghost.y = self.playerEntity.y - 8
  --     self.ghost.alive = true

  --     self.time = 0
  --     self.loop = 0

  --     local tombPixelData = Sprite(MetaSprite("tomb").Sprites[1].Id)

  --     DrawPixels(tombPixelData, self.playerEntity.x + self.scrollPos.x, self.playerEntity.y + self.scrollPos.y, 8, 8, false, false, DrawMode.TilemapCache)

  --     PlaySound(10, 3)

  --     -- Reduce the score before trying to restart the level
  --     score = score - 100

  --     if(score <= 0) then
  --       score = 0

  --       self.playerEntity.alive = false
  --       return

  --     end

  --   elseif(self.ghost ~= nil and self.ghost.alive) then

  --     self.time = self.time + timeDelta

  --     if(self.time > self.nextLevelDelay) then

  --       self.ghost.alive = false

  --       if(score <= 0) then

  --         SwitchScene(4)

  --         return

  --       else
  --         self:RestartLevel()
  --       end
  --     end

  --   end

  -- end

  -- if(stars == totalStars and self.unlockDoor == false) then

  --   self.unlockDoor = true

  --   -- TODO need to find a new API for this
  --   -- UpdateTiles(self.exitPos.c, self.exitPos.r, dooropen.width, dooropen.spriteIDs)

  -- end

  -- -- TODO need to add a door counter when player stands under it
  -- -- Test to see if the player has entered the door
  -- if(self.unlockDoor == true and self.playerEntity.alive == true and self.loop == 0) then

  --   -- TODO enable this when everything else works
  --   -- print("Exit")
  --   -- if(EntityCollision(self.playerEntity, self.exitPos)) then
  --   --   level = level + 1

  --   --   score = score + (100 * levelBonus)

  --   --   self.nextLevel = true

  --   --   self.time = 0

  --   --   self.playerEntity.alive = false

  --   --   PlaySound(14, 3)
  --   -- end

  -- end

  -- local totalCollected = stars - starCount

  -- if(totalCollected > 0) then

  --   for i = 1, totalCollected do

  --     local bonus = self.playerEntity.justKilled and 2 or 1

  --     score = score + ((10 * (self.loop + 1)) * bonus)

  --     -- Reset loop because we killed a bad guy
  --     self.loop = 0

  --     local id = starCount + i

  --     self:DrawStar("star-on", i)

  --     self:SpawnStar(self.playerEntity.x, self.playerEntity.y)

  --   end

  -- end

  -- -- Apply screen shake

  -- -- if(self.playerEntity.dy > 2 and self.nextLevel ~= true) then

  -- --   self.shakeX = math.random(0, self.loop)
  -- --   self.shakeY = math.random(0, self.loop)

  -- --   ScrollPosition(self.scrollPos.x + self.shakeX, self.scrollPos.y + self.shakeX)

  -- -- else
  -- --   self.shakeX = 0
  -- --   self.shakeY = 0
  -- -- end

  -- if(self.nextLevel == true) then

  --   self.time = self.time + timeDelta

  --   if(self.time > self.nextLevelDelay) then

  --     if(self.bossBattle == true ) then

  --       win = true

  --       SwitchScene(4)

  --       return

  --     else

  --       SwitchScene(2)
  --       return

  --     end
  --   end

  -- elseif(score > 0 and self.playerEntity.alive == true) then

  --   self.time = self.time + timeDelta

  --   if(self.time > 1) then
  --     self.time = 0
  --     score = score - levelBonus
  --   end

  -- end

  -- Update score
  -- if(self.scoreDisplay ~= self.score) then

  --   local diff = math.floor((self.score - self.scoreDisplay) / 4)

  --   -- print(score, self.scoreDisplay, diff)

  --   self.scoreDisplay = self.scoreDisplay + diff

  --   if(self.scoreDisplay < 0) then
  --     self.scoreDisplay = 0
  --   end

    -- Clear below
    DrawText(LeftPad(tostring(self.scoreDisplay), 5, "0"), Display().X - (6 * 4), Display().Y - 9, DrawMode.TilemapCache, "medium", 3, -4)

    -- DrawText(LeftPad(tostring(self.scoreDisplay), 6, "0"), 15 * 8, Display().Y - 9, DrawMode.TilemapCache, "medium" - 4)

  -- end

  -- if(self.bossBattle == true and self.boss ~= nil) then

  --   if(self.boss.alive == false and self.boss.value == 0) then

  --     self:SpawnStar(self.boss.x + 16, self.boss.y)

  --     for i = 1, 6 do

  --       self:SpawnDust(
  --         math.random(self.boss.x, self.boss.x + 32),
  --         math.random(self.boss.y, self.boss.y + 24),
  --         true
  --       )

  --     end

  --     self.boss = nil
  --   end

  -- end

end

function GameScene:Draw()

  if(self.startTimer > -1) then
    
    DrawRect(0, 0, Display().X, 7, 0, DrawMode.Sprite)
    DrawText("            EXITING GAME IN " .. self.startCount + 1, 3, -1, DrawMode.SpriteAbove, "medium", 3, -4)

  else

    for i = 1, self.totalInstances do

      local entity = self.instances[i]

      -- if(entity.alive == true) then
        entity:Draw(0, 0)
      -- end

    end

    -- local signSpriteData = in1

    -- DrawSprites({1, 2, 3, 4}, 0, 0, 4, false, false, DrawMode.Sprite, 0, true)

    -- Need to draw the player last since the order of sprite draw calls matters
    self.microPlatformer:Draw()

    -- DrawTilemap(0, 0, 20, 4, 168, 0, DrawMode.UI)
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

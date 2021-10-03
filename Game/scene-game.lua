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

  local _game = {}
  setmetatable(_game, GameScene) -- make Account handle lookup

  _game.levelOffset = 2

  _game.bounds = Display();

  _game.microPlatformer = MicroPlatformer:Init()

  _game.playerEntity = _game.microPlatformer.player

  _game.playerEntity.spriteData = player

  _game.microPlatformer.jumpSound = 4
  _game.microPlatformer.hitSound = 5
  _game.totalLevelTiles = levelSize.x * levelSize.y

  _game.exitSign = {x = 50, y = 50}
  _game.scoreDisplay = 0

  return _game

end

function GameScene:RestartLevel()
  -- Reset the player

  self.playerEntity.x = self.playerPos.x
  self.playerEntity.y = self.playerPos.y
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

  -- ClearUILayer()

  -- Clear old instances
  self.instances = {}
  self.totalInstances = 0
  self.boss = nil
  self.dust = {}
  self.stars = {}
  self.bossBattle = false
  self.ghost = nil

  self.playerPos = {x = (width * 8) / 2, y = 0}

  -- Reset global star counter

  stars = 0
  totalStars = 0


  -- Clear the exit position
  self.exitPos = nil

  -- GoToScreen(level + self.levelOffset)

  -- TODO for debugging
  level = 1

  -- LoadTilemap("tilemap-" .. level)
  

  -- Get the current scroll position
  local pos = ScrollPosition()

  -- Create a new vector for the scroll position
  self.scrollPos = NewPoint(pos.x, pos.y)

  -- Draw UI
  DrawMetaSprite("sky", 0, 0, false, false, DrawMode.TilemapCache)

  DrawMetaSprite("border-left", 0, 0, false, false, DrawMode.TilemapCache)
  DrawMetaSprite("border-top", 16, 0, false, false, DrawMode.TilemapCache)
  DrawMetaSprite("border-left", 160-16, 0, true, false, DrawMode.TilemapCache)

  -- Create two clouds
  for i = 1, 2 do

    local cloud = Cloud:Init(
      math.random(0, Display().X),
      math.random(7, Display().Y - 6),
      i < 2 and "cloud-small" or "cloud-large",
      math.random(5, 10)
    )

    -- Add the instance to the list to render
    table.insert(self.instances, cloud)

  end

  local total = TilemapSize().X * TilemapSize().Y

  for i = 1, total do
    
    local pos = CalculatePosition(i-1, TilemapSize().X)

    local flag = Flag(pos.X, pos.Y)

    -- Convert the x and y to pixels
    local x = pos.X * 8
    local y = pos.Y * 8

    local entity = nil

    if(flag == 2) then -- Door

      if(self.exitPos == nil) then

        -- Save the first tile position
        self.exitPos = {
          c = realC,
          r = realR,
          x = x,
          y = y,
          w = 16,
          h = 16
        }

      end

      -- Make sure that the door tiles are displaying a locked door
      DrawMetaSprite("door-close", x, y, false, false, DrawMode.TilemapCache)
    --   UpdateTiles(self.exitPos.c, self.exitPos.r, doorlocked.width, doorlocked.spriteIDs)

    elseif(flag == 8) then -- Enemy
    --   -- TODO need to know what kind of enemy it is and how many stars its worth
      entity = Enemy:Init(x, y)
      totalStars = totalStars + 1

      Tile(pos.X, pos.Y, -1)

    elseif(flag == 9) then

    --   if(self.bossBattle ~= true) then

    --     -- TODO need to know what kind of enemy it is and how many stars its worth
    --     entity = Boss:Init(x, y)

    --     self.bossBattle = true
    --     self.boss = entity

    --     totalStars = totalStars + 4

    --   end

    elseif(flag == 13) then -- Player

    --   -- Reset the player
      self.playerPos.x = x
      self.playerPos.y = y
      

    --   print("FOUND PLAYER")

    end

    if(entity ~= nil) then

      -- Add the instance to the list to render
      table.insert(self.instances, entity)

    end

    self:RestartLevel()

  end

  -- Update the total instance count
  self.totalInstances = #self.instances

  -- Draw stars
  for i = 1, totalStars do

    self:DrawStar("star-off", i)

  end

  DrawText(LeftPad(tostring(score), 6, "0"), 32, 1, DrawMode.Tile, "default")

end

function GameScene:DrawStar(name, index)

  local star = MetaSprite(name)

  local tmpC = 2 + ((index - 1) * star.Width)
  
  DrawMetaSprite(star, (tmpC) * 8, 3, false, false, DrawMode.TilemapCache)

end

function GameScene:Update(timeDelta)

  timeDelta = timeDelta / 1000


  local starCount = stars

  local wasAlive = self.playerEntity.alive

  -- Reset scroll position
  -- ScrollPosition(self.scrollPos.x, self.scrollPos.y)


  -- Update the player logic first so we always have the correct player x and y pos
  self.microPlatformer:Update(timeDelta)

  if(self.playerEntity.y > 144) then
    self.loop = self.loop + 1

    if(self.loop < 2)then
      PlaySound(11, 3)

    elseif(self.loop < 4) then
      PlaySound(12, 3)
    else
      PlaySound(13, 3)

    end

    if(self.loop > 5) then
      self.loop = 5
    end

  end

  -- If player hits the ground, apply bonus or kill them
  if(self.playerEntity.isgrounded == true) then

    if(self.loop > 0) then

      self.playerEntity.dy = -(self.playerEntity.jumpvel * (self.loop / 4))

      score = score - (20 * self.loop)

      if(score < 0) then
        score = 0
      end

      if(self.loop >= 5 and score <= 0) then
        self.playerEntity.alive = false
      end

      -- Reset loop counter
      self.loop = 0

      self:SpawnDust(self.playerEntity.x, self.playerEntity.y)

      PlaySound(7, 3)

    elseif(self.playerEntity.justKilled == true) then
      self.playerEntity.justKilled = false
    end

  end

  -- Wrap player's x and y position after the platform collision was calculated
  self.playerEntity.x = Repeat(self.playerEntity.x, self.bounds.x)
  self.playerEntity.y = Repeat(self.playerEntity.y, self.bounds.y)

  -- Loop through all of the entities
  for i = 1, self.totalInstances do

    -- Get the current entity in the list
    local entity = self.instances[i]

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

      local frames = {
        ghost1,
        ghost2
      }

      if(self.ghost == nil) then
        self.ghost = Ghost:Init(0, 0, frames, .4, 10)
        table.insert(self.instances, self.ghost)
        self.totalInstances = #self.instances
      end

      self.ghost.x = self.playerEntity.x - 8
      self.ghost.y = self.playerEntity.y - 8
      self.ghost.alive = true

      self.time = 0
      self.loop = 0

      local tombPixelData = Sprite(MetaSprite("tomb").Sprites[1].Id)

      DrawPixels(tombPixelData, self.playerEntity.x + self.scrollPos.x, self.playerEntity.y + self.scrollPos.y, 8, 8, false, false, DrawMode.TilemapCache)

      PlaySound(10, 3)

      -- Reduce the score before trying to restart the level
      score = score - 100

      if(score <= 0) then
        score = 0

        self.playerEntity.alive = false
        return

      end

    elseif(self.ghost ~= nil and self.ghost.alive) then

      self.time = self.time + timeDelta

      if(self.time > self.nextLevelDelay) then

        self.ghost.alive = false

        if(score <= 0) then

          SwitchScene(4)

          return

        else
          self:RestartLevel()
        end
      end

    end

  end

  if(stars == totalStars and self.unlockDoor == false) then

    self.unlockDoor = true

    -- TODO need to find a new API for this
    -- UpdateTiles(self.exitPos.c, self.exitPos.r, dooropen.width, dooropen.spriteIDs)

  end

  -- TODO need to add a door counter when player stands under it
  -- Test to see if the player has entered the door
  if(self.unlockDoor == true and self.playerEntity.alive == true and self.loop == 0) then

    -- TODO enable this when everything else works
    -- print("Exit")
    -- if(EntityCollision(self.playerEntity, self.exitPos)) then
    --   level = level + 1

    --   score = score + (100 * levelBonus)

    --   self.nextLevel = true

    --   self.time = 0

    --   self.playerEntity.alive = false

    --   PlaySound(14, 3)
    -- end

  end

  local totalCollected = stars - starCount

  if(totalCollected > 0) then

    for i = 1, totalCollected do

      local bonus = self.playerEntity.justKilled and 2 or 1

      score = score + ((10 * (self.loop + 1)) * bonus)

      -- Reset loop because we killed a bad guy
      self.loop = 0

      local id = starCount + i

      self:DrawStar("star-on", i)

      self:SpawnStar(self.playerEntity.x, self.playerEntity.y)

    end

  end

  -- Apply screen shake

  -- if(self.playerEntity.dy > 2 and self.nextLevel ~= true) then

  --   self.shakeX = math.random(0, self.loop)
  --   self.shakeY = math.random(0, self.loop)

  --   ScrollPosition(self.scrollPos.x + self.shakeX, self.scrollPos.y + self.shakeX)

  -- else
  --   self.shakeX = 0
  --   self.shakeY = 0
  -- end

  if(self.nextLevel == true) then

    self.time = self.time + timeDelta

    if(self.time > self.nextLevelDelay) then

      if(self.bossBattle == true ) then

        win = true

        SwitchScene(4)

        return

      else

        SwitchScene(2)
        return

      end
    end

  elseif(score > 0 and self.playerEntity.alive == true) then

    self.time = self.time + timeDelta

    if(self.time > 1) then
      self.time = 0
      score = score - levelBonus
    end

  end

  -- Update score
  if(self.scoreDisplay ~= score) then

    local diff = math.floor((score - self.scoreDisplay) / 4)

    -- print(score, self.scoreDisplay, diff)

    self.scoreDisplay = self.scoreDisplay + diff

    if(self.scoreDisplay < 0) then
      self.scoreDisplay = 0
    end

    DrawText(LeftPad(tostring(self.scoreDisplay), 6, "0"), 32, 1, DrawMode.Tile, "default")

  end

  if(self.bossBattle == true and self.boss ~= nil) then

    if(self.boss.alive == false and self.boss.value == 0) then

      self:SpawnStar(self.boss.x + 16, self.boss.y)

      for i = 1, 6 do

        self:SpawnDust(
          math.random(self.boss.x, self.boss.x + 32),
          math.random(self.boss.y, self.boss.y + 24),
          true
        )

      end

      self.boss = nil
    end

  end

end

function GameScene:Draw()

  for i = 1, self.totalInstances do

    local entity = self.instances[i]

    if(entity.alive == true) then
      entity:Draw(self.shakeX, - self.shakeY)
    end

  end

  -- local signSpriteData = in1

  -- DrawSprites({1, 2, 3, 4}, 0, 0, 4, false, false, DrawMode.Sprite, 0, true)

  -- Need to draw the player last since the order of sprite draw calls matters
  self.microPlatformer:Draw()

  -- DrawTilemap(0, 0, 20, 4, 168, 0, DrawMode.UI)

end

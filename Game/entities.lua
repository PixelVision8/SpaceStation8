--[[
  Pixel Vision 8 - ReaperBoy v2
  Copyright (C) 2017, Pixel Vision 8 (http://pixelvision8.com)
  Created by Jesse Freeman (@jessefreeman)

  Licensed under the Microsoft Public License (MS-PL) License.

  Learn more about making Pixel Vision 8 games at http://pixelvision8.com
]]--

-- Core entity logic
function CreateEntity(x, y, spriteName)

  local entity = {
    x = x,
    y = y,
    flipH = false,
    flipV = false,
    offset = 0,
    spriteData = MetaSprite(spriteName),
    drawMode = DrawMode.SpriteAbove,
    alive = true
  }

  if(entity.spriteData ~= nil) then
    entity.w = entity.spriteData.Width
    entity.h = entity.spriteData.Height--math.floor(#entity.spriteData.spriteIDs / entity.spriteData.width)
  end

  print("Entity", spriteName, dump(entity))

  return entity

end

function DrawEntity(entity, offsetX, offsetY)

  offsetX = offsetX or 0
  offsetY = offsetY or 0

  if(entity.spriteData ~= nil) then
    DrawMetaSprite(entity.spriteData, entity.x + offsetX, entity.y + offsetY, entity.flipH, entity.flipV, entity.drawMode, entity.offset)
  end
end

function AnimateEntity(entity, timeDelta)

  -- Look to see if we should animate this entity
  if(entity.animate == true) then

    -- Calculate the next animation frame time
    entity.time = entity.time + timeDelta

    -- Test to see if the time is greater than the delay
    if(entity.time > entity.delay) then

      -- Reset the animation time
      entity.time = 0

      -- Move to the next frame
      entity.frame = entity.frame + 1

      -- If the frame is greater than the total number of frames, reset the frame counter
      if(entity.frame > #entity.frames) then

        -- Reset the frame to 1 since this is the first frame id
        entity.frame = 1

      end

      entity.spriteData = entity.frames[entity.frame]

    end

  end

end

function CreateAnimatedEntity(x, y, frames, delay)

  -- Leverage the create entity method for setting up a table
  local entity = CreateEntity(x, y)

  -- since there was no sprite name, we need to reconfigure the data by hand
  entity.spriteData = frames[1]

  -- Recalculate size
  if(entity.spriteData ~= nil) then
    entity.w = entity.spriteData.Width * 8
    entity.h = entity.spriteData.Height * 8--(math.floor(#entity.spriteData.spriteIDs / entity.spriteData.width)) * 8
  end

  -- Add animation properties
  entity.time = 0
  entity.delay = .1
  entity.frame = 1
  entity.frames = frames
  entity.animate = true

  return entity

end

function EntityCollision(rect1, rect2)

  -- print("A",rect1, "B", rect2)

  return (
    rect1.x < (rect2.x + rect2.w) and
    (rect1.x + rect1.w) > rect2.x and
    rect1.y < (rect2.y + rect2.h) and
    (rect1.h + rect1.y) > rect2.y
  )
end

-- Collectable Star Entity
Collectable = {}
Collectable.__index = Collectable

function Collectable:Init(x, y)

  local frames = {
    _G["star1"],
    _G["star2"],
    _G["star3"],
    _G["star4"],
  }

  local _collectable = CreateAnimatedEntity(x, y, frames, delay) -- our new object
  setmetatable(_collectable, Collectable) -- make Account handle lookup

  return _collectable

end

function Collectable:Update(timeDelta)
  AnimateEntity(self, timeDelta)
end

function Collectable:Draw()
  DrawEntity(self)
end

function Collectable:Collision(player)

  print("Collectable")
  -- Test to see if there is a collision with the supplied rect
  local collision = EntityCollision(player, self)

  if(collision == true) then

    -- TODO increase score
    self.alive = false

    -- TODO need to figure out how to scale the player's physic back after every star collected
    player.jumpvel = player.jumpvel / 2




  end

end

-- Enemy Entity
Enemy = {}
Enemy.__index = Enemy

function Enemy:Init(x, y)

  local frames = {
    MetaSprite("enemy-walker-1"),
    MetaSprite("enemy-walker-2"),
  }

  local _enemy = CreateAnimatedEntity(x, y, frames, delay) -- our new object
  setmetatable(_enemy, Enemy) -- make Account handle lookup

  _enemy.speed = 10
  _enemy.flipH = (math.random(1, 10) > 5)
  _enemy.death = MetaSprite("enemy-walker-4")
  _enemy.deathDelay = .3
  _enemy.value = 1

  return _enemy

end

function Enemy:Update(timeDelta)

  -- Look to see if entity is dying
  if(self.dying == true) then
    self.time = self.time + timeDelta

    if(self.time > self.deathDelay) then
      self.dying = false
      self.alive = false
    end

    return

  end

  -- If the entity is dead, don't update
  if(self.alive == false) then
    return
  end

  local offset = self.speed * timeDelta

  if(self.flipH == true) then
    offset = offset * - 1
  end

  self.x = self.x + offset

  local c = math.floor((self.x + ScrollPosition().x) / 8)
  local r = math.floor((self.y + ScrollPosition().y) / 8) + 1

  -- If moving to the right, need to make sure we look ahead of the sprite so add 1 tile to the value
  if(self.flipH == false) then
    c = c + 1
  end

  if(Flag(c, r) == -1) then
    self.flipH = not self.flipH
  end

  AnimateEntity(self, timeDelta)

end

function Enemy:Draw(offsetX, offsetY)

  -- If the entity is dead, don't update
  if(self.alive == false) then
    return
  end

  DrawEntity(self, offsetX, offsetY)
end

function Enemy:Collision(player)

  -- Only do collision checking if the entity is alive and not dying
  if(self.alive == false or self.dying == true and player.alive == false) then
    return
  end

  -- print("Enemy")
  -- Test to see if there is a collision with the supplied rect
  local collision = EntityCollision(self, player)

  if(collision == true) then

    -- If the player is above the bad guy and falling down, kill the bad guy
    if(player.y < self.y and math.abs(player.dy) > 0) then

      if(player.dy > 4 or player.justKilled == true) then

        self.dying = true
        self.time = 0
        self.frame = 1
        self.spriteData = self.death

        stars = stars + self.value

        self.value = 0

        player.justKilled = true


        PlaySound(8, 3)

      end

      player.dy = -(player.jumpvel * .5)

      PlaySound(9, 3)

    else

      player.alive = false

    end

  end

end

-- Cloud Star Entity
Cloud = {}
Cloud.__index = Cloud

function Cloud:Init(x, y, spriteName, speed)

  local _cloud = CreateEntity(x, y, spriteName) -- our new object
  setmetatable(_cloud, Cloud) -- make Account handle lookup

  _cloud.drawMode = DrawMode.SpriteBelow
  _cloud.speed = cloudSpeed or 10

  return _cloud

end

function Cloud:Update(timeDelta)

  timeDelta = timeDelta/1000

  self.x = self.x + (self.speed * timeDelta)

end

function Cloud:Draw(offsetX, offsetY)
  DrawEntity(self, offsetX, offsetY)
  -- print("Draw Cloud", offsetX, offsetY)
end

-- Ghost Star Entity
Ghost = {}
Ghost.__index = Ghost

function Ghost:Init(x, y, frames, delay, speed)

  local _ghost = CreateAnimatedEntity(x, y, frames, delay) -- our new object
  setmetatable(_ghost, Ghost) -- make Account handle lookup

  _ghost.speed = speed or 10

  return _ghost

end

function Ghost:Update(timeDelta)
  if(self.alive == false) then
    return
  end

  self.y = self.y - (self.speed * timeDelta)

  -- Remove the ghost when it goes too high
  if(self.y < 0) then
    self.alive = false
  end
  -- if(self.y < self.distance) then
  --   self.alive = false
  -- end

  AnimateEntity(self, timeDelta)

end

function Ghost:Draw(offsetX, offsetY)

  if(self.alive == false) then
    return
  end

  DrawEntity(self, offsetX, offsetY)

end

-- Star Star Entity
Star = {}
Star.__index = Star

function Star:Init(x, y)

  local frames = {
    star1,
    star2,
    star3,
    star4
  }

  local _star = CreateAnimatedEntity(x, y, frames, .2) -- our new object
  setmetatable(_star, Star) -- make Account handle lookup

  _star.speed = speed or 10
  -- _Star.distance = y - 32
  _star.lifeDelay = .5
  _star.lifeTime = 0

  return _star

end

function Star:Update(timeDelta)

  if(self.alive == false) then
    return
  end

  self.lifeTime = self.lifeTime + timeDelta

  if(self.lifeTime > self.lifeDelay and self.alive == true) then

    self.alive = false

  end

  self.y = self.y - (self.speed * timeDelta)

  AnimateEntity(self, timeDelta)

end

function Star:Draw(offsetX, offsetY)

  if(self.alive == false) then
    return
  end

  DrawEntity(self, offsetX, offsetY)

end

-- Dust Star Entity
Dust = {}
Dust.__index = Dust

function Dust:Init(x, y)

  local frames = {
    MetaSprite("dust-1"),
    MetaSprite("dust-2"),
    MetaSprite("dust-3"),
    MetaSprite("dust-4")
  }

  local _dust = CreateAnimatedEntity(x, y, frames, .2) -- our new object
  setmetatable(_dust, Dust) -- make Account handle lookup

  return _dust

end

function Dust:Update(timeDelta)

  if(self.alive == false) then
    return
  end

  if(self.frame >= #self.frames) then
    self.alive = false
  else
    AnimateEntity(self, timeDelta)
  end

end

function Dust:Draw(offsetX, offsetY)

  if(self.alive == false) then
    return
  end

  DrawEntity(self, offsetX, offsetY)

end

-- Boss Entity
Boss = {}
Boss.__index = Boss

function Boss:Init(x, y)

  local frames = {
    _G["bossidle1"],
    _G["bossidle2"],
    _G["bossidle3"],
  }

  local _boss = CreateAnimatedEntity(x, y, frames, .4) -- our new object
  setmetatable(_boss, Boss) -- make Account handle lookup

  _boss.speed = 5
  _boss.flipH = (math.random(1, 10) > 5)
  _boss.death = _G["bosshurt"]
  _boss.deathDelay = 2
  _boss.value = 4

  return _boss

end

function Boss:Update(timeDelta)

  if(self.deathPos ~= nil and self.value < 1) then
    self.x = math.random(self.deathPos.x - 2, self.deathPos.x + 2)
    -- self.y = math.random(self.deathPos.y, self.deathPos.y - 2)
  end
  -- Look to see if entity is dying
  if(self.dying == true) then
    self.time = self.time + timeDelta

    if(self.time > self.deathDelay) then


      if(self.value <= 0) then
        self.dying = false
        self.alive = false

        stars = stars + 1

      else
        self.dying = false
        self.alive = true
        self.time = 0
      end
    end

    return

  end

  -- If the entity is dead, don't update
  if(self.alive == false) then
    return
  end

  local offset = self.speed * timeDelta

  if(self.flipH == true) then
    offset = offset * - 1
  end

  self.x = self.x + offset

  local c = math.floor((self.x + ScrollPosition().x) / 8) + 2
  local r = math.floor((self.y + ScrollPosition().y) / 8) + 1

  if(Flag(c, r) == -1) then
    self.flipH = not self.flipH
  end

  AnimateEntity(self, timeDelta)

end

function Boss:Draw(offsetX, offsetY)

  -- If the entity is dead, don't update
  if(self.alive == false) then
    return
  end

  DrawEntity(self, offsetX, offsetY)
end

function Boss:Collision(player)

  -- Only do collision checking if the entity is alive and not dying

  -- -- Test to see if there is a collision with the supplied rect
  local collision = EntityCollision(self, player)

  if(collision == true) then

    -- If the player is above the bad guy and falling down, kill the bad guy
    if(player.y < self.y and math.abs(player.dy) > 0) then

      if(self.alive == false or self.dying == true and player.alive == false) then
        -- Do nothing

      else

        if(player.dy > 4 or player.justKilled == true) then

          self.dying = true
          self.time = 0
          self.frame = 1
          self.spriteData = self.death

          self.deathPos = {x = self.x, y = self.y}

          PlaySound(8, 3)

          if(self.value > 1) then
            stars = stars + 1

          end

          self.value = self.value - 1

        end


      end

      player.dy = -(player.jumpvel * 1)

      PlaySound(9, 3)

    else

      player.alive = false

    end

  end

end

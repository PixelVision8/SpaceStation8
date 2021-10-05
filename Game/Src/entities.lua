--[[
  Pixel Vision 8 - ReaperBoy v2
  Copyright (C) 2017, Pixel Vision 8 (http://pixelvision8.com)
  Created by Jesse Freeman (@jessefreeman)

  Licensed under the Microsoft Public License (MS-PL) License.

  Learn more about making Pixel Vision 8 games at http://pixelvision8.com
]]--

-- Core entity logic
function CreateEntity(x, y, spriteName)

  -- All entities are hard coded to 8x8 in this game
  local entity = {
    
    hitRect = NewRect(x, y, 8, 8),
    x = x,
    y = y,
    flipH = false,
    flipV = false,
    offset = 0,
    metaSprite = MetaSprite(spriteName),
    drawMode = DrawMode.Sprite,
    alive = true
  }

  entity.spriteId = entity.metaSprite.Sprites[1].Id

  return entity

end

function DrawEntity(entity)

  if(entity.metaSprite ~= nil) then
    
    DrawSprite(entity.spriteId, entity.hitRect.X, entity.hitRect.Y, entity.flipH, entity.flipV, entity.drawMode, entity.offset)

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
      entity.frame = Repeat(entity.frame + 1, entity.frames)

      entity.spriteId = entity.metaSprite.Sprites[entity.frame + 1].Id

    end

  end

end

function CreateAnimatedEntity(x, y, spriteName)

  -- Leverage the create entity method for setting up a table
  local entity = CreateEntity(x, y, spriteName)

  -- Add animation properties
  entity.time = 0
  entity.delay = .1
  entity.frame = 1
  entity.frames = #entity.metaSprite.Sprites
  entity.animate = true

  return entity

end

function EntityCollision(rect1, rect2)
  return rect1.Contains(rect2)
end

-- Enemy Entity
Enemy = {}
Enemy.__index = Enemy

function Enemy:Init(x, y, flip)

  local _enemy = CreateAnimatedEntity(x, y, "enemy-move") -- our new object
  setmetatable(_enemy, Enemy) -- make Account handle lookup

  _enemy.speed = 10
  _enemy.flipH = flip or false -- TODO need to read the flip on the tile
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

  -- We need to keep track of fractions
  self.x = self.x + offset

  if(self.x < -2) then
    self.x = Display().X - 4
  elseif(self.x > Display().X - 4) then
    self.x = 2
  end

  -- save the real x ot the hitRect which converts it to an int
  self.hitRect.X = self.x--Repeat(self.x, Display().X-4) -- TODO need to figure out how to wrap around the screenRepeat(self.x, Display().X-4)

  

  local c = Repeat(math.floor(self.hitRect.X / 8), 20)
  local r = math.floor(self.hitRect.Y / 8)

  
  -- If moving to the right, need to make sure we look ahead of the sprite so add 1 tile to the value
  if(self.flipH == false) then
    c = Repeat(c + 1, 20)
  end

    -- DrawRect(c * 8, r * 8, 1, 1, 3, DrawMode.Sprite)
    -- DrawRect(c * 8, (r+1) * 8, 1, 1, 3, DrawMode.Sprite)

    if(Flag(c, r) == SOLID or Flag(c, r + 1) == EMPTY) then
      self.flipH = not self.flipH
    end

  AnimateEntity(self, timeDelta)

end

function Enemy:Draw()

  -- If the entity is dead, don't update
  if(self.alive == false) then
    return
  end

  DrawEntity(self)
end

function Enemy:Collision(player)

  -- Only do collision checking if the entity is alive and not dying
  if(self.alive == false or self.dying == true and player.alive == false) then
    return
  end

  -- Test to see if there is a collision with the supplied rect
  local collision = EntityCollision(self.hitRect, player.hitRect)

  if(collision == true) then

      player.alive = false

  end

end

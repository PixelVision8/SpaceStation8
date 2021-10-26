--[[
  ## Space Station 8 `entities.lua`

  This script contains helper functions for creating entities in the  game. Entities are any game object that can interact with another object. This can include static entities such as collectables or animated entities such as the player or enemies.

  These global function will help you mange the state of an entity in your game. Simply create a custom entity instance and call these functions as needed.

  Learn more about making Pixel Vision 8 games at http://docs.pixelvision8.com
]]--

--[[
  The `CreateEntity()` function helps standardize the creation of entities in the game. This will return a table with all of the properties that make up an entity such as it's position, which direction it is facing, the default sprite, and whether it is alive or not.

  This function also adds the properties it needs to manage changing the sprite id  on each frame. Animated entities simply update the `spriteId` at set intervals allowing you to still use the `DrawEntity()` function. You'll need to call the `AnimateEntity()` function in order to advance the animation on each frame.
]]--
function CreateEntity(x, y, spriteName, delay)

  -- We want to make sure that the delay always has a value so if its nil, we set it to 500 ms (1/2 second) as the default value.
  delay = delay or 500

  -- When creating an entity, you supply the same `x`, `y`, and `spriteName` arguments as a regular entity and include a `delay` in milliseconds between animated frames.

  -- This table is to store and manage en entity's state. You can continue to build upon this by adding more properties to the table that the function returns. We can use the `spriteName` for this entity's timer id and create a flag called `animate` to see if an entity should be animated or not.
  local entity = {
    hitRect = NewRect(x, y, SpriteSize().X, SpriteSize().Y),
    flipH = false,
    flipV = false,
    offset = 0,
    metaSprite = MetaSprite(spriteName),
    drawMode = DrawMode.Sprite,
    alive = true,
    timerId = spriteName,
    animate = true,
    frame = 1
  }

  -- It's important to note that all entities are hard coded to 8x8 which we get by looking at the `SpriteSize()` functions `X` and `Y` values. This helps simplify collision detection, animation, and other logic in the game.

  -- Assigns a default sprite that the `Draw()` function will display on every frame.
  entity.spriteId = entity.metaSprite.Sprites[1].Id

  -- The default animation will be the first frame of the meta sprite assigned when creating the entity table. Since all entities are 8x8 we can use a single meta sprite to store all the frames of the entity. For the default entity, the `spriteName` argument is used to look up the meta sprite the entity uses.

  -- Once we get the entity table we can save the name for this entity's timer for based on the spriteName and calculate the total frames. We'll also create a flag called `animate` to see if an entity should be animated or not.
  entity.frames = #entity.metaSprite.Sprites

  -- In order to track the entity's current frame, we'll need to register a new timer with the `spriteName`. Pixel Vision 8 `CreateTimer()` and `TimerTriggered()` allow you to register multiple timers for a game and keep track of each one by the `timerId` you assign them.
  NewTimer(entity.timerId, delay)

  -- Its important to note that creating a new entity will change the time delay for every entity that uses this table. This helps you sync up animations between similar entities. If you want each instance to have a different start frame, you can change it on instantiation as well as change the name of the timer once this entity table is returned.

  -- Finally we return the new entity's table.
  return entity

end

-- This simple `DrawEntity()` function displays the entity on the screen each frame. It requires an entity table to read the `metaSprite` and `spriteId` properties.
function DrawEntity(entity)

  -- We need to make sure their is a meta sprite before trying to render or calling `DrawSprite()` would throw an error.
  if(entity.metaSprite ~= nil) then
    
    -- We draw the entity's `spriteId` to the display. It uses all of the entities properties like the x, y, flip, and color offset values. You can also change the `DrawMode` of the entity incase you want some entities to be rendered at different levels.
    DrawSprite(entity.spriteId, entity.hitRect.X, entity.hitRect.Y, entity.flipH, entity.flipV, entity.drawMode, entity.offset)

  end

end

-- The `AnimateEntity()` function is used to animate an entity. It requires an entity table to read the `metaSprite`, `spriteId`, and `timerId` properties.
function AnimateEntity(entity)

  -- Before we can animate an entity, we need to make sure its `animate` flag is set to true.
  if(entity.animate == true) then

    -- Before we can advance to the next spriteId, we need to make sure the timer has has been triggered.
    if(TimerTriggered(entity.timerId) == true) then

      -- `TimerTriggered()` function checks to see if the timer has been triggered. It will only remain true for a single frame and is reset to false when the next frame begins to update.

      -- When the time between animations is reached, we can advance to the next spriteId. We use the `Repeate()` function to loop the animation back to the first frame if the current frame is the last frame.
      entity.frame = Repeat(entity.frame + 1, entity.frames)

      -- Now we just need set the entity's current `spriteId` to the current `frame` value. 
      entity.spriteId = entity.metaSprite.Sprites[entity.frame + 1].Id
      
      -- We assume that each sprite inside of the meta data is a single frame of animation. This works because all the entities in the game are hard coded to be 8x8 sprites. If we had larger entities, we'd need to make a new `AnimateEntity()` and `DrawEntity()` function that would take the size of the entity into account.
      
    end

  end

end
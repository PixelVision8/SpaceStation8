--[[
    ## Space Station 8 `entity-enemy.lua`

    This is a generic enemy for Space Station 8. The enemy has a very simple AI that makes it walk forward until it hits a wall or the end of a platform and then turns around.

    Learn more about making Pixel Vision 8 games at http://docs.pixelvision8.com
]]--

-- We need to create a table to store all of the enemy's functions.
Enemy = {}
Enemy.__index = Enemy

-- This is the constructor for the enemy. We need to pass in an `x`, `y`, and `flip` value.
function Enemy:Init(x, y, flip)

  -- To configure the base properties for the enemy, we need to create a new entity by calling `CreateEntity()`. This will return a table that we can use to configure the enemy's properties. We just need to pass in the `x` and `y` position of the enemy and we hard code the sprite name to `enemy-move` with an animation delay of `200` milliseconds.
  local enemy = CreateEntity(x, y, "enemy-move", 200)

  -- We need to set the flip value for the enemy. If `flip` is not passed in, we set it to `false` by default.
  enemy.flipH = flip or false

  -- We assign how many pixels the enemy should move each frame to `enemy.speed`. Since we want the enemy to move at a slower speed than the player, we set `.3` as the speed.
  enemy.speed = .3

  -- The last thing we need to configure is setting the 'type' and `checkCollisions` values. We set the type to `"enemy"` and we set the `checkCollisions` to `true` so the enemy knows to check for the player when detecting collisions with other entities.
  enemy.type = TYPE_ENEMY
  enemy.checkAgainst = TYPE_PLAYER

  -- Now that the enemy is configured, we can set the `enemy` metatable as `Enemy` so it will inherit all of the functions we define here.
  setmetatable(enemy, Enemy)

  -- Finally, we can return an instance of the enemy to use elsewhere in the game.
  return enemy

end

-- This is the main update loop for the enemy. It will be called automatically by the micro-platformer once the enemy is added to it.
function Enemy:Update(timeDelta)

  -- Before we get started it's important to call out that there is no way to kill an enemy in this game so we don't check to see if the enemy is dead.

  -- First, we want to test if the enemy is falling which can happen if it spawns above a platform or solid tile.
  if(self.isGrounded == false) then
    
    -- If the enemy is falling, we want to make sure that we don't set a movement flag  by exiting the function.
    return

  end

  -- This is where we calculate if the direction the enemy should be moving. We do this by setting the `input.left` flag to the `flipH` value. By default, all entities are facing right which would make `flipH` false. Knowing this, we can set the `input.right` flag to the opposite of `flipH` via the `not` keyword.
  self.input.Left = self.flipH
  self.input.Right = not self.flipH

  end

  -- The enemy's `LateUpdate()` function is called after the `Update()` function by the micro-platformer when all off the collisions have been calculated and resolved.
  function Enemy:LateUpdate(timeDelta)
  
    -- The enemy's AI is very simple. It will move forward until it hits a wall or the end of a platform and then turn around.
    if(Flag(self.forward.C, self.bottom.R) == EMPTY or self.nextFlag == SOLID) then

      -- We are going to take advantage of a few pre-calculated positions and flag values the micro-platformer provides. In order to determine if the enemy is about to walk off a platform, we can use the `forward.X` and `bottom.Y` values. When it comes to detecting walls, we already know what the `nextFlag` is so we can use that value and check to see if it is solid.

      -- Since we have determined that the enemy is about to walk off a platform or has hit a wall, we can get the inverse of the `flipH` value which will make the enemy turn around on the next frame.
      self.flipH = not self.flipH

    end

    -- With the direction and state sorted out, all we need to do is update the enemy's sprite by calling the `AnimatedEntity()`.
    AnimateEntity(self)

    -- The `AnimationEntity()` will test the entity's animation timer and move the sprite to the next sprite id if the timer has been trigger on this frame.

  end

  -- The enemy's `Draw()` function is called by the micro-platformer after both `Update()` and `LateUpdate()` functions are call.
  function Enemy:Draw()

    -- There isn't much for the entity to do when drawing except call the `DrawEntity()` function which places the sprite id calculated by the `LateUpdate()` function.
    DrawEntity(self)

  end
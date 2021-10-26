--[[
    ## Space Station 8 `entity-player.lua`

    The player entity is a unique entity that Pixel Vision 8's input APIs control. It also contains specific logic for displaying the correct sprite id based on the player's current state.

    Learn more about making Pixel Vision 8 games at http://docs.pixelvision8.com
]]--

-- We need to create a table to store all of the player's functions.
Player = {}
Player.__index = Player

-- This is the constructor for the player. We need to pass in an `x`, `y', and `flip` value.
function Player:Init(x, y, flip)

  -- To configure the base properties for the player, we need to create a new entity by calling `CreateEntity()`. This will return a table that we can use to configure the player's properties. We need to pass in the player's `x` and `y' position, then hard code the sprite name to `player` with an animation delay of `200` milliseconds.
  local player = CreateEntity(x, y, "player", 200)

  -- The player also has some custom properties that we can set in the `player` table, such as the `speed` at which the player can move.
  player.speed = 1

  -- We can also set the `flipH` value for the player depending on if we want the player to face right (`false`) or left (`true`). If a `flip` argument isn't supplied, we default it to `false`.
  player.flipH = flip or false

  -- Here, we set the player to the `TYPE_PLAYER` constant defined in the micro-platformer. Other entities can check against this type and know if they are colliding with the player when setting their `checkAgainst` value to `TYPE_PLAYER`.
  player.type = TYPE_PLAYER

  -- All entities need to be added to the `entities` table. When they are, some entities will be able to collide with each other. To help resolve these collisions, we need to define a collision `type`. If you do not provide a `checkAgainst` value, the entity will not collide with anything. We want all the game's enemies to look for the player, not the other way around. 

  -- The player has custom animation logic that is not used by other entities in the game. We need to set a `spriteIdOffset` value which we'll use later when determining the correct sprite id to draw to the display.
  player.spriteIdOffset = 0

  -- Each animation is made up of 2 frames.-- The player is made up of a collection of different sprites based on moving, jumping, or idle. We need to set the `spriteId` to the correct sprite id based on the player's current state. To animate the player, we'll increase the `spriteIdOffset` value by `1` every frame so the animation will play correctly.

  -- Now that the player is configured, we can set the `player` metatable as `Player` to inherit all of the functions we define here.
  setmetatable(player, Player)

  -- Registering a Lua table as a metatable allows us to modify its behavior and attach meta methods defined on the source table.
  
  -- Finally, we can return an instance of the player to use elsewhere in the game.
  return player

end

-- The `Update` function is called by the game engine every frame. We can use this function to update the player's state based on what keys are pressed.
function Player:Update(timeDelta)

  -- We'll look at each of the buttons currently being pressed and update the player's `input` table based on whether the button is down (`true`) or up (`false`).
  self.input.Up = Button(Buttons.Up)
  self.input.Down = Button(Buttons.Down)

  --[[
    Pixel Vision 8's `Button()` function allows us to abstract all input in the game. The function requires a button `name`, an input `type`, and a controller `id`. By default, just calling the `Button()` function with the button name will return `true` if the button is down or `false` if it is up.
   
    You can learn more about the `Button()` function at https://github.com/PixelVision8/PixelVision8/wiki/button

  ]]--
  
  -- Now we can test if the player should move right or left based on the input.
  self.input.Right = Button(Buttons.Right)
  self.input.Left = Button(Buttons.Left)

  -- Now that we have the input, we can update the player's direction based on the input. We start with testing to see if the player is being told to move to the left.
  if(self.input.Left == true) then

    -- Since all the sprites in the game face to the right by default, we need to flip the player to face left by setting the `flipH` value to `true`.
    self.flipH = true

  -- If the player is not being told to move to the left, we need to test if the player is being told to move to the right.
  elseif(self.input.Right == true) then

    -- It's important to note that we don't need to flip the player to face right if the player is not being told to move to the right. The reason for this is to keep the player from resetting to its default `flipH` value of `false`. If we used an else here instead of an elseif, the player would automatically be set to false based on the next line of code we are about to add.

    -- Since the `input.Right` value is `true`, we need to set the `flipH` value back to `false`.
    self.flipH = false

  end

  -- The last thing we need to do is test if either of the controller's action buttons are being pressed.
  self.input.A = Button(Buttons.A)
  self.input.B = Button(Buttons.B)

  -- Finally, we don't do any calculations here. Once the player instance is added to the micro-platformer, it will read the input state and determine what should happen.
  
end

-- Normally, we would do all of our calculations in the `Update()` function, but that gets called before the physics are calculated, so we move some of the update logic into the `LateUpdate()` function since we know it will be called after all of the other entities are updated. We can use this function to update the player's state based on any collision calculations that were done in the micro-platformer; 's `Update` function.
function Player:LateUpdate(timeDelta)

  -- First, we want to check to see if the player is out of bounds or has collided with spikes.
  if(self.outOfBounds == true or self.spikeCollision == true) then

    -- When we detect a collision, we change the alive flag to false letting the game know that the player has died.
    self.alive = false

  end

  -- Next, we want to detect if the player is dead before we set any other flags on the player.
  if(self.alive == false) then
    
    -- Since the player is dead, there is nothing to do and we exit out of the player's `LateUpdate()` function. This also insures that we don't try to collect the key or gem in the next block of code.
    return

  end

  -- Since the player is alive, we can then test for any of the collectables in the game, starting with the `KEY`.
  if(self.currentFlag == KEY) then
    
    -- Since the player is collecting the key, we need to set the `keyCollected` flag to true. The game will know that the player has collected the key and will update the UI and unlock the door.
    self.hasKey = true
  
  -- There is another collectible in the game, the `GEM`. We can test for this by checking the player's `currentFlag` like the key.
  elseif(self.currentFlag == GEM) then

    -- Since the player is collecting the gem, we need to set the `gemCollected` flag to true.
    self.collectedGem = true

    -- Once the game knows that the player has collected a gem, it will increase the score and reset the `collectedGem` flag to false.-- We don't reset this value because the game scene itself will do that once it detects that the flag has been set to true. This way the player doesn't have to know anything about what to do when a gem is collected, just that it has done it.

  end

end

--The `Draw()` the game engine is called after the `LateUpdate` function has finished and all collisions have been calculated. We can use this function to draw the player's sprite to the display.
function Player:Draw()

  -- First, we want to detect if the player is dead before we draw the player to the display.
  if(self.alive == false) then
    
    -- Since the player is dead, there is nothing to render, and we exit out of the player's `Draw()` function.
    return

  end

  -- If the player is still alive, we need to check if it should move to the next animation frame. We do this by looking up the entity `timerId` by calling the `TimerTriggered()` function. If the timer has been triggered, it will return `true` for a single frame.
  if(TimerTriggered(self.timerId)) then
  
    -- Now can use this to determine the next sprite Id for the player's animation by incrementing the `spriteOffset` value.
    self.spriteOffset = Repeat(self.spriteOffset + 1, 2)

    -- This is because we only have two sprites for each of the player's animation states.-- It's important to note that we use Pixel Vision 8's `Repeat()` function to keep the `spriteOffset` value between 0 and 1. We'll add this value later once we determine what the player's current animation state is. 

  end

  -- The player has several animations states: idle, walking, jumping, falling, and climbing. We start resetting the player's state to `IDLE` on each frame before we derive the player's actual state.
  local spriteId = IDLE

  -- The first state we test for is if the player is on a ladder and that it's not standing on the ground. 
  if(self.currentFlag == LADDER and self.isGrounded == false) then
    
    -- If the player is on a ladder, we can assume that it is climbing and we set the spriteId to `PLAYER_CLIMB`.
    spriteId = PLAYER_CLIMB
    
    -- The climbing animation is a bit different than the other states in that we only want to animate the player if they are moving up or down the ladder. We can do this by checking the `input.Up` and `input.Down` values.
    if(self.input.Up == true or self.input.Down == true) then
      
      -- Since we are moving on the ladder, we can add the `spriteOffset` value to the spriteId to get the correct sprite for this frame.
      spriteId = PLAYER_CLIMB + self.spriteOffset
      
      -- To clarify what is happening here, it's important to call out that all player states start at the first sprite id in the animation. So, if we are moving up the ladder, we need to add the `spriteOffset` value to the `PLAYER_CLIMB` value to get the correct id. Since we are repeating the `spriteOffset` once it gets past the maximum number of animation frames, which is `2`, we can get the correct sprite for the current frame.

    end
  
  -- Next, we will test out if the player is jumping by checking if the `dY` value is greater than 0, which means it's moving up the screen.
  elseif(self.dY < 0) then

    -- Now, we can set the player's state to `PLAYER_JUMP`.
    spriteId = PLAYER_JUMP

    -- The jumping animation is also different in that there is only one frame. So we don't add the `spriteOffset` value to the `PLAYER_JUMP` value while the player is in the air.
  
  -- If the player's `dY` value is less than 0, it means that the player is falling.
  elseif(self.dY > 0) then
    
    -- As we did with the jump state, since there is only one frame for falling, we don't need to add the `spriteOffset` value to the `PLAYER_FALL` value.
    spriteId = PLAYER_FALL

  -- At this point, we can test to see if we move left or right based on the `dX` value. If the `dX` value is greater than `0`, it means the player is moving right, and if it's less than `0`, the player is moving left. So we test to see that `dX` does not equal `0`.
  elseif(self.dX ~= 0) then
  
    -- In Lua, we can use the `~` character in front of an equals to check that the value is not equal to `0` in this case.

    -- Now, we can add the `spriteOffset` to the `PLAYER_WALK` value to get the correct sprite for this frame.
    spriteId = PLAYER_WALK + self.spriteOffset

  else

    -- If the player is not moving, we can set the spriteId to `PLAYER_IDLE` and add the `spriteOffset` value to get the correct frame.
    spriteId = PLAYER_IDLE + self.spriteOffset

  end

  -- Now that we have the correct `spriteId`, we need to find the actual sprite id from the meta sprite and set it to the player's own `spriteId`.
  self.spriteId = self.metaSprite.Sprites[spriteId].Id

  -- Finally, we can draw the player to the display by using the default `DrawEntity()` function all other entities use in the game.
  DrawEntity(self)

end

-- The last thing we need to do is handle when an entity collision with the player. Since the enemies in the game only look for a player collision, we can assume that when the micro-platformer calls the `Collision()` function, an enemy instance will be passed in.
function Player:Collision(entity)

  -- At this point, we set the player's `alive` flag to false, and it will be killed in the next frame.
  self.alive = false

  -- If you expand the game to have different entity types, you could test the `entity.type` and do something specific based on the returned type.

end
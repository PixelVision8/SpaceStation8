--[[
    ## Space Station 8 `micro-platformer.lua`

	The micro-platformer handles all physics in the game. It is responsible for moving entities, applying gravity, and testing collisions. This is a very simple implementation of a physics engine you can use by registering an entity and then calling the `Update()` function. Each entity is given all the properties it needs to work to calculate its movement and the `Update()` function will move the entity based on its velocity and gravity.

    Learn more about making Pixel Vision 8 games at http://docs.pixelvision8.com
]]--

-- We need to create a table that represent an instance of the micro-platformer physics engine. Once we define this table, we can add our functions onto it.
MicroPlatformer = {} 
MicroPlatformer.__index = MicroPlatformer

-- These are the entity state constants that the physics engine will assign to each entity once it finishes all the calculations for that state.
IDLE, WALKING, JUMP, FALL, LADDER = 1, 2, 3, 4, 5

-- These represent two different entity types usually denoted as `TypeA` and `TypeB`. These are used to determine if two entities are colliding. Since the game only deals with two types of entities, we can just use these two types. 
TYPE_PLAYER, TYPE_ENEMY = 1, 2

-- This is the constructor for the micro platformer. It is responsible for creating the physics engine instance we'll use to handle all the physics calculations in the game.
function MicroPlatformer:Init()

	-- We need to create a table that stores all of the properties for the micro-platformer instance. Well be able to reference any of the properties of this table by using the `self` keyword after we register the metatable. Also, we are going to precalculate the bounds of the screen so we don't have to do this every frame.
	local _microPlatformer = {
		bounds = NewRect(0, 2, Display().X - 6, Display().Y - 6)
	}

	-- When calculating the right and bottom bounds of the screen we subtract 6 pixels. Each entity is 8 pixels and we want to make sure that enough of the entity goes out of bounds before wrapping around to the other side of the screen. If we don't add enough pixels there is a potential that if the entity is moving slow it could fall because we won't be able to accurately detect a solid tile on the other side of the screen.

	-- Now we can register the table and associate it with the `MicroPlatformer` table defined at the entity.top. This will give the `_microPlatformer` table the functions of the `MicroPlatformer` table.
	setmetatable(_microPlatformer, MicroPlatformer)
	
	-- Finally, we can return the `_microPlatformer` table and treat it like a unique instance of the `MicroPlatformer` table.
	return _microPlatformer

end

-- Before we start the physics engine, we need to reset all of the physic properties. This is done by calling the `Reset()` function.
function MicroPlatformer:Reset()

	-- We need to reset the physics engine by resetting all of the properties. We'll set the gravity to 0.2, clear the entities table, and set the `totalEntities` to 0.
	self.gravity = 0.2
	self.entities = {}
	self.totalEntities = 0
	self.maxSpeed = 2

	-- If we are running the micro-platformer for the first time, we need to create al of these properties on the instance of the micro-platformer.

end

-- This is the function registers an entity with the physics engine. We'll need to keep tract of all the entities that are registered with the physics engine so we can test for collisions. Also we'll need to add properties to each entity so they work correctly when we test for collisions.
function MicroPlatformer:AddEntity(entity)
	
	-- We are not using a Point for tracking the entity's position. Instead, we will be using two properties so we can store floating numbers. When we actually move the entity, we'll convert it an integer by assigning it to the `hitRect`'s `X` and `Y` properties.
	entity.x = entity.hitRect.X
	entity.y = entity.hitRect.Y

	-- These two properties are used to track the entity's velocity. We'll use them to calculate the entity's position when we update the entity on each frame.
	entity.dX = 0
	entity.dY = 0

	-- We need to keep track of the entity's state. We'll use this to determine what the entity currently stating on a solid tile..
	entity.isGrounded = false
	
	-- These two properties are used to apply a force to the entity. We'll use them when the entity is climbing or jumping.
	entity.climbval = 1
	entity.jumpvel = 3.0
	
	-- Each entity is responsible for keeping track of its own input. The micro-platformer will look at these values to determine if the entity is trying to move or jump.
	entity.input = {
		Up = false,
		Right = false,
		Down = false,
		Left = false,
		A = false,
		B = false
	}

	-- Since we want to abstract out the input, each entity will need to modify these flags. For example, the player will test for user input and update each of these flags. The enemy's AI will set the input flags based on what action it determine it should be doing.

	-- We'll use the following points to keep track of the entity's collision calculations.
	entity.currentFlagPos = NewPoint()
	entity.center = NewPoint()
	entity.forward = NewPoint()
	entity.top = NewPoint()
	entity.bottom = NewPoint()

	-- As we calculate different collision points for the entity, there may be at time where the entity itself will need to do additional tests. To save us some time, we can use these points without having to recalculate it each time.
	
	-- Once the entity is configured, we'll add it to the list of entities that the micro-platformer manages.
	table.insert(self.entities, entity)

	-- The last thing we want to do is increase the total number of entities the platformer is managing on each frame.
	self.totalEntities = #self.entities

	-- We do optimizations like this to help cut down on recalculating the same values over and over again. Dynamically getting a total on a table is expensive so since the number is fixed on each game, we can just update it every time a new entity is added and not have to worry about it later on when we are iterating over all the entities.

end

-- This is the function that will update all of the entities that are registered with the physics engine. It is responsible for moving the entities based on their velocity and gravity. It also tests for collisions and resolves them. Finally, it accepts a `timeDelta` parameter that represents the amount of time that has passed since the last frame.
function MicroPlatformer:Update(timeDelta)

	-- We need to loop through all of the entities and calculate their physics.
	for i = 1, self.totalEntities do

		-- Here we are going to get a reference to the current entity based on the index of the loop.
		local entity = self.entities[i]

		-- Before we do anything, we need to make sure the entity is not `nil` and the `alive` property is not set to false.
		if(entity== nil or entity.alive == false) then

			-- Since we don't want to update an entity that doesn't exist or is dead, we'll simply move onto the next entity in the loop.
			break

		end

		-- Before we do any calculation, we'll update the entity so we can determine any direction input or other changes in the entity's state.
		entity:Update(timeDelta)
		
		--There are two update states for entities, `Update()` and `LateUpdate()`. The normal update state is used to configure the entity's state before we do any physics calculations. The `LateUpdate()` function is called after all of the collision calculations are complete.

		-- We need to calculate all of the points around the entity that we need to test the physics with. Each entity will test the center, in front, the bottom, and the top for solid tiles. We start by calculating the center point of the entity
		entity.center.X = entity.x + (entity.hitRect.Width / 2)
		entity.center.Y = entity.y + (entity.hitRect.Height / 2)

		-- In oder to find the center of an entity, we use its `x` and `y` properties plus half of the `width` and `height`. We don't use the `hitRect`'s `X` and `Y` properties because we want to account for any fractional movement between frames.
		
		-- We'll update the entity's `currentFlagPos` property to the center of the entity.
		entity.currentFlagPos.X = entity.center.C
		entity.currentFlagPos.Y = entity.center.R

		-- Pixel Vision 8's `Point` class has two getters that allow you to quickly get the current point's column (`C`) and row (`R`) values. This helps us to avoid having to calculate the column and row values each time we need to access them.

		-- Now we want to look up the current flag value of the tile the entity is inside of. We set this on the entity so it can also use the value for any additional calculations it may need to do in the next frame.
		entity.currentFlag = Flag(
			entity.currentFlagPos.X,
			entity.currentFlagPos.Y
		)

		-- We are going to copy the `gravity` property value from the micro-platform so we can make adjustments to during our collision calculations without havening to reset the global gravity on each frame.
		local gravity = self.gravity
		
		-- Next, we need to keep track of the entity's `startX` incase we need to move them back to their original position if they are trying to move into a solid tile.
		local startX = entity.x

		-- Now we begin testing an entity's input to determine if it is trying to jump. We also need to make sure that the entity is on the ground or some kind of solid tile as well.
		if (entity.input.A or entity.input.B) and entity.isGrounded then
			
			-- We are going to set the entity's velocity to the `jumpvel` value.
			entity.dY = -entity.jumpvel

			--[[
			Note that we are setting the entity's velocity to a negative value. This is because in order to move up, we need to subtract from the entity's `Y` position. The 0,0 point is the top left corner of the screen so if the player is below that, subtracting from the `Y` position will naturally move the player up.

			Since we want to adjust the entity based on other influences such as moving left or right and gravity, we apply this velocity and add it to the entity's actual position at the end of all of the calculations.
			]]--

			-- Since we are jumping, we change the entity's `state` property to out constant `JUMP`.
			entity.state = JUMP
			
		end
		
		-- Now we need to check if we are inside of a ladder  tile.
		if(entity.currentFlag == LADDER) then

			-- We set the gravity to 0 so the entity will not be affected by gravity while it is on a ladder.
			gravity = 0

			-- If the entity's `Up` input is true, we'll want to move the entity up the ladder.
			if(entity.input.Up) then

				-- When the entity is moving up the ladder, we want to center it's `x` position on the center of the ladder tile.
				entity.x =entity.currentFlagPos.X * 8

				-- We also want to set the entity's upward velocity to the a negative `climbval` value.
				entity.dY = -entity.climbval
			
			-- If the entity's `Down` input is true, we'll want to move the entity down the ladder.
			elseif(entity.input.Down) then
			
				-- When the entity is moving down the ladder, we want to center it's `x` position on the center of the ladder tile.
				entity.x = entity.currentFlagPos.X * 8

				-- Now we can set the entity's downward velocity to the a positive `climbval` value.
				entity.dY = entity.climbval
			
			else
				
				-- The last thing we want to do is set the entity's `dY` to 0 so the entity doesn't continue to move up or down the ladder.
				entity.dY = 0
			
			end

		end

		-- At this point we are ready to calculate if the player is moving left or right. Before we do that, we'll reset the entity horizontal velocity to 0.
		entity.dX = 0

		-- First we need to check if the entity is trying to move left.
		if (entity.input.Left) then

			-- We set the entity's horizontal velocity to a negative `movevel` value.
			entity.dX = -entity.speed
			
			-- Also, we'll set the entity's `dir` property to `true` so we know which direction it is facing later on when it's drawn to the display.
			entity.dir = true
		
		-- Next, we need to check if the entity is trying to move right.
		elseif (entity.input.Right) then

		-- It's important to note that we only want one horizontal input at a time so you can only move left or right which is why we use an `elseif` here.
			
			-- We set the entity's horizontal velocity to a positive `movevel` value.
			entity.dX = entity.speed
			
			-- We also set the entity's `dir` property to `false`, which is the default direction of our entity sprites so it's drawn correctly to the display.
			entity.dir = false

		end

		-- Now its time to apply the horizontal velocity to the entity's position. We do this by adding the entity's horizontal velocity to the entity's `x` position.
		entity.x = entity.x + entity.dX

		-- It's important to note that entities could have a fractional speed, i.e. not move in a whole pixel on each frame, so we track this in the entity's `x` property which is a generic number type verses using a `Point` which always has a whole number since it's an integer.
		
		-- Before we continue on with the vertical calculations, we need to check if the entity is going off the left side of the screen.
		if(entity.x < - self.bounds.X) then

			-- When we go past the left boundary, we want to move the entity back to the right side of the screen.
			entity.x = self.bounds.Width

		-- Now we need to check if the entity is going off the right side of the screen.
		elseif(entity.x > self.bounds.Width) then
			
			-- When we go past the right boundary, we want to move the entity back to the left side of the screen.
			entity.x = self.bounds.X
		
		end

		-- This point will keep track of the tile flag in front of the entity. 
		entity.forward.X = Repeat(entity.x + (entity.dir == false and entity.hitRect.Width - 1 or 1), self.bounds.Width)
		entity.forward.y = entity.center.Y

		-- The entity's `forward` point is different based on which direction it is facing. Before we set the `forward.X` value, we test if the direction is false, we use the current `x` position plus the `hitRect.Width` to find the right side of the entity's hitRect. We also call `Repeat` on the `forward.X` value so we can wrap it around the screen.

		-- Now we need to check if the entity is about to hit a wall by looking at the next tile. We do this by using the 'forward` point we defined earlier.
		entity.nextFlag = Flag(
			math.floor(entity.forward.C),
			math.floor(entity.forward.R)
		)

		-- With the value of the next tile, we can now check to see if its `flag` property is `SOLID`.
		if (entity.nextFlag == SOLID) then
			
			-- If the entity hits a solid so move them back to their original starting position, `startX`.
			entity.x = startX

		end

		-- With horizontal movement accounted for it's time for the entity to accumulate gravity
		entity.dY = entity.dY + gravity

		-- Remember that moving down can be done by adding a positive number to the entity's `Y` position. By adding gravity to the entity's velocity we can adjust their next `y` position by how much gravity is applied on this frame.

		-- With the velocity calculated, we can now add it to the entity's `y` position.
		entity.y = entity.y + entity.dY

		-- At this point we can just calculate the top and bottom points of the entity by looking at the corresponding direction on the entity's `hitRect`.
		entity.bottom.X = entity.center.X
		entity.bottom.Y = entity.y + entity.hitRect.Height

		-- At the beginning of our next set of calculations, we are just going to assume that the entity is off the ground until we determine otherwise.
		entity.isGrounded = false

		-- We only want to check for solid floor tiles when the entity is moving down.
		if (entity.dY > 0) then

			-- To calculate the flag of the tile directly below the entity, we need to use the bottom point of the entity inside of a tile.
			entity.bottomFlag = Flag(
				entity.bottom.C,
				entity.bottom.R
			)

			-- The first thing we want to do is check if the entity is landing on a spike tile.
			if (entity.bottomFlag == SPIKE) then

				-- Set the `spikeCollision` property to `true` so we when the entity hits a spike tile. Not all entities will die if they land on a spike so we let the entity handle it the next time it updates its state.
				entity.spikeCollision = true

			end

			-- Now we need to check if the entity is falling off the bottom of the screen.
			if(entity.y > self.bounds.Height) then

				-- Set the `outOfBonds` property to `true` so we know when the entity has fallen off the bottom of the screen. Not all entities will die if they fall off the bottom of the screen so we let the entity handle it the next time it updates its state.
				entity.outOfBounds = true

				-- Since falling off the screen means it's no longer being drawn to the display, we wan to stop all other calculations on this frame and move onto the next entity in the loop.
				break

			-- Now we need to check if the entity is landing on a solid tile or a platform tile.
			elseif (entity.bottomFlag == SOLID or entity.bottomFlag == PLATFORM) then

				-- Platform tiles are special tiles that allow you  to jump onto them from below but not fall through them once the entity lands on them.
				
				-- We want to make sure that the entity is always on top of the solid tile it is landing on.
				entity.y = math.floor((entity.y) / 8) * 8

				-- Now that we have determined that the entity is on a solid tile, we can set the entity's `isGrounded` property to `true` and clear the entity's downward velocity.
				entity.isGrounded = true
				entity.dY = 0

			-- If we are not landing on a solid tile, we need to check if the entity is above and inside of a ladder tile.
			elseif(entity.bottomFlag == LADDER and entity.currentFlag ~= LADDER) then

				-- Ladders are like solid tiles in that we consider the entity is standing and we need to clear the downward velocity.
				entity.isGrounded = true
				entity.dY = 0

				-- Where a tile differs from a solid tile is that a ladder tile allows the entity to climb down when the `input.Down` flag is set to true. If we don't test for this, the entity will not be able to move down the ladder when standing on it.
				if(entity.input.Down) then

					-- Moving down a tile is the same as moving horizontally. We just need to add the entity's `speed` to the entity's `y` position.
					entity.y = entity.y + entity.speed
				
				else
				
					-- If the entity is not moving down, we want to make sure that the entity is always on top of the ladder tile it is standing on.
					entity.y = math.floor((entity.y) / 8) * 8
				
				end
			
			-- The last thing we need to do when an entity is moving down is to make sure that it doesn't accumulate too much speed.
			elseif(entity.dY > self.maxSpeed) then

				-- We'll use the micro-platformer's `maxSpeed` to determine the maximum downward velocity an entity can have.
				entity.dY = self.maxSpeed
			
			end

		end

		-- We subtract 1 from the top of the entity's `y` position to make the entity can't jump when its standing directly under a solid tile.
		entity.top.X = entity.center.X
		entity.top.Y = entity.y-1

		-- With all of the other calculations done, we can now check if the entity is moving up.
		if entity.dY < 0 then

			-- We need to find the tile flag directly above the entity.
			entity.topFlag = Flag(
				entity.top.C,
				entity.top.R
			)
			
			-- The first thing we want to test is if the entity is jumping on a spike tile.
			if (entity.topFlag == SPIKE) then
				
				-- If the entity does jump into a spoke above it, we need to set `spikeCollision` property to `true`. Not all entities will die if they land on a spike so we let the entity handle it the next time it updates its state.
				entity.spikeCollision = true

			end

			-- If the entity's `topFlag` is `SOLID` then we want to make sure that the entity stops moving
			if (entity.topFlag == SOLID) then
			
				-- We want to make sure that the entity is always on top of the solid tile it is standing on so we snap the `y` position to the top of the tile.
				entity.y = math.floor((entity.y + 8) / 8) * 8
				
				-- Once we move the entity to the top of the tile, we can set the entity's `dY` to 0 so it stops moving.
				entity.dY = 0
			
			end

		end

		-- We need to copy the entity's `x` and `y` to the rectangle so we can do the final collision detection
		entity.hitRect.X = entity.x
		entity.hitRect.Y = entity.y

		-- The last thing we need to do is check to see if the entity should test for a collision with another entity. We do this by making sure the `.checkAgainst` property is not nil.
		if(entity.checkAgainst ~= nil) then
			
			-- Now we need to loop back over all the entities as we look to see if we have a collision.
			for j = 1, self.totalEntities do

				-- We will test that each entity's type matches this entity's `.checkAgainst` property. If there is a match we'll also check if the `hitRects` overlap.
				if(self.entities[j].type == entity.checkAgainst and entity.hitRect.Intersects(self.entities[j].hitRect)) then
					
					-- Once we have identified a mathc, we can call the entity's `Collision()` function and pass the current entity into it.
					self.entities[j]:Collision(entity)
					
					-- Since we don't want to hard code any of the collision logic, each entity is responsible for managing the collision and deciding what to do with the entity that is being passed in.

				end
			
			end

		end

		entity:LateUpdate(timeDelta)

	end

end

-- The final thing we need to do is draw all of the entities to the display. The `Draw()` function simply loops through all of the entities and calls their `Draw()` function. Everything else is handled inside of the entity itself.
function MicroPlatformer:Draw()

	-- Since we precalculated the total entities, we just need to loop through all of them.
	for i = 1, self.totalEntities do

		-- We can just call the entity's `Draw()` function directly by referencing the current entity in the entities array.
		self.entities[i]:Draw()

	end

end

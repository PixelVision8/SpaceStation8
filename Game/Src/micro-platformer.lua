--[[
	Micro Platformer - Platforming Framework in 100 lines of code.
	Created by Matt Hughson (@matthughson | http://www.matthughson.com/)

	Update to PV8 v1.5 API by Jesse Freeman (@jessefreeman | http://pixelvision8.com)
]]--

--[[
	The goal of this cart is to demonstrate a very basic
	platforming engine in under 100 lines of *code*, while
	still maintaining an organized and documented game.

	It isn't meant to be a demo of doing as much as possible, in
	as little code as possible. The 100 line limit is just
	meant to encourage people to realize "You can make a game
	with very little coding!"

	This will hopefully give new users a simple and easy to
	understand starting point for their own platforming games.

	Note: Collision routine is based on mario bros 2 and
	mckids, where we use collision points rather than a box.
	this has some interesting bugs but if it was good enough for
	miyamoto, its good enough for me!
--]]

MicroPlatformer = {}
MicroPlatformer.__index = MicroPlatformer

function MicroPlatformer:Init()

	-- Create a new object for the instance and register it
	local _microPlatformer = {
		grav = 0.2
	}

	setmetatable(_microPlatformer, MicroPlatformer)

	--player information
	_microPlatformer.player = 
	{
		--velocity
		dx = 0,
		dy = 0,
		hitRect = NewRect(0, 0, 8, 8),
		isgrounded = false,
		spriteID = 1,
		climbval = 1,
		jumpvel = 3.0,
		time = 0,
		delay = .1,
		jumpSound = -1,
		hitSound = -1,
		spriteOffset = 0,
		alive = true,
		hasKey = false
	}
	
	return _microPlatformer

end

--called 60 times per second
function MicroPlatformer:Update(timeDelta)

	if(self.player == nil or self.player.alive == false) then
		return
	end

	local hitRect = self.player.hitRect


	-- get the scroll position
	-- local scrollPos = ScrollPosition()

	local center = hitRect.Center
	local forward = NewPoint(self.player.dir == false and (hitRect.Right -1) or (hitRect.Left + 1), center.Y)
	local bottom = NewPoint(center.X, hitRect.Bottom + 1)
	local top = NewPoint(center.X, hitRect.Top - 1)

	-- DrawRect(center.X, center.Y, 1, 1, 3, DrawMode.SpriteAbove)
	-- DrawRect(forward.X, forward.Y, 1, 1, 3, DrawMode.SpriteAbove)
	-- DrawRect(bottom.X, bottom.Y, 1, 1, 3, DrawMode.SpriteAbove)
	-- DrawRect(top.X, top.Y, 1, 1, 3, DrawMode.SpriteAbove)
	
	-- Keep track of all the collision areas around the player
	self.currentFlagPos = NewPoint(math.floor(center.X/8), math.floor(center.Y/8))
	self.currentFlag = Flag(self.currentFlagPos.X, self.currentFlagPos.Y)

	-- DrawRect(math.floor(center.X/8) * 8, math.floor(center.Y/8) * 8, 8, 8, 9, DrawMode.SpriteBelow)


	local grav = self.grav
	
	self.player.time = self.player.time + timeDelta

	--remember where we started
	local startx = self.player.hitRect.X

	if (Button(Buttons.A) or Button(Buttons.B)) and self.player.isgrounded then
		--launch the player upwards
		self.player.dy = -self.player.jumpvel

		if(self.jumpSound > - 1) then
			PlaySound(self.jumpSound, 3)
		end
	end
	
	-- Handle moving on the ladder
	if(self.currentFlag == LADDER) then

		grav = 0

		if(Button(Buttons.Up)) then
			hitRect.X = math.floor(center.X/8) * 8
			self.player.dy = -self.player.climbval
		elseif(Button(Buttons.Down)) then
			hitRect.X = math.floor(center.X/8) * 8
			self.player.dy = self.player.climbval
		else
			self.player.dy = 0
		end

	end

	-- Reset player x
	self.player.dx = 0

	-- Apply player x direction
	if (Button(Buttons.Left)) then --left
		self.player.dx = -1
		self.player.dir = true
	end
	if (Button(Buttons.Right)) then --right
		self.player.dx = 1
		self.player.dir = false
	end

	--move the player left/right
	self.player.hitRect.X = self.player.hitRect.X + self.player.dx

	local nextFlag = Flag(math.floor(forward.X/8), math.floor(forward.Y/8))


	-- print("nextFlag", nextFlag, math.floor(forward.X/8), math.floor(forward.Y/8), self.player.hitRect.X)

	-- DrawRect(math.floor(forward.X/8) * 8, math.floor(forward.Y/8) * 8, 8, 8, 8, DrawMode.SpriteBelow)

	--We use flag 0 (solid black) to represent solid walls. This is controlled
	if (nextFlag == SOLID) then
		--they hit a wall so move them
		--back to their original pos.
		--it should really move them to
		--the edge of the wall but this
		--mostly works and is simpler.
		self.player.hitRect.X = startx
	end

	--accumulate gravity
	self.player.dy = self.player.dy + grav

	--apply gravity to the players position.
	self.player.hitRect.Y = self.player.hitRect.Y + self.player.dy

	--assume they are floating
	--until we determine otherwise
	self.player.isgrounded = false

	--only check for floors when
	--moving downward
	if self.player.dy >= 0 then

		
		--check bottom center of the
		--player.
		local bottomFlag = Flag(math.floor(bottom.X/8), math.floor(bottom.Y/8))

		-- print(bottomFlag, self.player.hitRect)

		-- DrawRect(math.floor(bottom.X/8) * 8, math.floor(bottom.Y/8) * 8, 8, 8, 1, DrawMode.SpriteBelow)

		--look for a solid tile
		if (bottomFlag == SPIKE  or self.player.hitRect.Y > (Display().Y - 16)) then

			-- print("Kill Player")

			self.player.alive = false

		elseif (bottomFlag == SOLID or bottomFlag == PLATFORM) then
			
			--place player on top of tile
			self.player.hitRect.Y = math.floor((self.player.hitRect.Y) / 8) * 8
			--halt velocity
			self.player.dy = 0

			--allow jumping again
			self.player.isgrounded = true

			if(Button(Buttons.Down) and bottomFlag == PLATFORM) then

				self.player.hitRect.Y = self.player.hitRect.Y + 10

			end
			
			-- DrawRect(math.floor(testX) * 8, math.floor(testY) * 8, 8, 8, 1, DrawMode.SpriteBelow)
		
		elseif (bottomFlag == LADDER and Button(Buttons.Down) == false ) then
			
		
			--halt velocity
			self.player.dy = 0
		
			--allow jumping again
			-- self.player.isgrounded = true
		

		-- Make sure the player doesn't accumulate speed if in a falling loop
		elseif(self.player.dy > 5) then
			self.player.dy = 5
		end

	end

	--only check for ceilings when
	--moving up
	if self.player.dy < 0 then

		local topFlag = Flag(math.floor(top.X/8), math.floor(top.Y/8))
		-- DrawRect(math.floor(top.X/8) * 8, math.floor(top.Y/8) * 8, 8, 8, 4, DrawMode.SpriteBelow)

		
		--look for solid tile
		if (topFlag == SOLID) then
			--position self.player right below
			--ceiling
			self.player.hitRect.Y = math.floor((self.player.hitRect.Y + 8) / 8) * 8
			--halt upward velocity
			self.player.dy = 0

		end
	end

	-- Increment animation frame
	-- Test for the next animation frame
	if(self.player.time > self.player.delay) then

		-- Reset the time
		self.player.time = 0

		self.player.spriteOffset = Repeat(self.player.spriteOffset + 1, 2)

	end
	
	-- Reset player sprite direction
	self.spriteDir = self.player.dir

	-- Climbing
	if(self.currentFlag == LADDER and self.player.isgrounded == false) then
		
		self.player.spriteID = PLAYER_CLIMB 
		
		-- Animate climbing when moving up or down a ladder
		if(Button(Buttons.Up) == true or Button(Buttons.Down) == true) then
			
			self.player.spriteId = PLAYER_CLIMB + self.player.spriteOffset
			
			-- Flip the sprite to animate up the ladder
			self.spriteDir = self.player.spriteOffset == 0

		end
	
	-- Jumping
	elseif(self.player.dy < 0) then
		self.player.spriteID = PLAYER_JUMP
	
	-- Falling
	elseif(self.player.dy > 0) then
		self.player.spriteID = PLAYER_FALL
	
	-- Moving
	elseif(self.player.dx ~= 0) then
		
		-- Increment the sprite
		self.player.spriteID = PLAYER_WALK + self.player.spriteOffset

	else

		-- Idle so use the first sprite
		self.player.spriteID = PLAYER_IDLE + self.player.spriteOffset
	end

end

function MicroPlatformer:Draw()

	if(self.player.alive == false) then
		return
	end

	if(self.player.sprites ~= nil) then

		--draw the player, represented as sprite 1.
		DrawSprite(self.player.sprites[self.player.spriteID].Id, self.player.hitRect.X, self.player.hitRect.Y, self.spriteDir, false, DrawMode.Sprite)--draw player
	end
end

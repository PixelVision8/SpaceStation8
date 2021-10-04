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
	local _microPlatformer = {}
	setmetatable(_microPlatformer, MicroPlatformer)


	--player information
	_microPlatformer.player = 
	{
		--position, representing the top left of
		--of the player sprite.
		-- x = 72,
		-- y = 16,
		-- w = 8,
		-- h = 8,
		--velocity
		dx = 0,
		dy = 0,

		hitRect = NewRect(0, 0, 8, 8),

		-- dir = false,
		--is the player standing on
		--the ground. used to determine
		--if they can jump.
		isgrounded = false,
		spriteID = 1,
		climbval = 1,
		--how fast the player is launched
		--into the air when jumping.
		jumpvel = 3.0,
		time = 0,
		delay = .1,
		
	}
	
	-- _microPlatformer.bounds = DisplaySize()

	-- gravity per frame
	_microPlatformer.grav = 0.2

	-- _microPlatformer.solidFlagId = 0
	-- _microPlatformer.ladderFlagId = 9

	-- stores the flag globally since it's used every frame
	_microPlatformer.flag = -1

	_microPlatformer.jumpSound = -1
	_microPlatformer.hitSound = -1

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



	DrawRect(center.X, center.Y, 1, 1, 3, DrawMode.SpriteAbove)
	DrawRect(forward.X, forward.Y, 1, 1, 3, DrawMode.SpriteAbove)
	DrawRect(bottom.X, bottom.Y, 1, 1, 3, DrawMode.SpriteAbove)
	DrawRect(top.X, top.Y, 1, 1, 3, DrawMode.SpriteAbove)
	

	-- Find the center position
	-- local centerX = self.player.dir == true and 4 or 3
	-- local centerY = 4
	-- local forwardX = centerX + (self.player.dir == true and -5 or 5)
	-- local forwardX = centerX + (self.player.dir == true and -5 or 5)
	-- local bottomY = 9

	-- Draw Center
	-- DrawRect(self.player.hitRect.Center.X, self.player.hitRect.Center.X, 1, 1, 3, DrawMode.SpriteAbove)

	-- Draw Forward
	-- DrawRect(self.player.hitRect.X + forwardX, self.player.hitRect.Y + centerY, 1, 1, 3, DrawMode.SpriteAbove)
	
	-- -- Draw Forward
	-- DrawRect(self.player.hitRect.X + forwardX, self.player.hitRect.Y + centerY, 1, 1, 3, DrawMode.SpriteAbove)
	
	-- print(math.floor((self.player.hitRect.X + centerX)/8), math.floor((self.player.hitRect.Y + centerY)/8))

	-- Keep track of all the collision areas around the player
	local currentFlag = Flag(math.floor(center.X/8), math.floor(center.Y/8))
	DrawRect(math.floor(center.X/8) * 8, math.floor(center.Y/8) * 8, 8, 8, 9, DrawMode.SpriteBelow)


	

	-- local topFlag = -1
	-- -- local bottomFlag = -1

	-- if(currentFlag > -1) then
	-- 	print("currentFlag", currentFlag)
	-- end


	-- if(nextFlag > -1) then
	-- 	print("nextFlag", nextFlag)
	-- end

	local grav = self.grav
	
	-- local offsetX = self.player.dir == true and 4 or 2
	-- local offsetY = 8

	-- local testX = ((self.player.hitRect.X + offsetX + scrollPos.X) / 8)
	-- local testY = 0--((self.player.hitRect.Y + offsetY+ scrollPos.Y) / 8)


	self.player.time = self.player.time + timeDelta

	--remember where we started
	local startx = self.player.hitRect.X

	

	-- local xoffset = 0 --moving left check the left side of sprite.

	-- offsetX = 0
	-- offsetY = 7

	-- testX = ((self.player.hitRect.X + offsetX + scrollPos.X) / 8)
	-- testY = ((self.player.hitRect.Y + offsetY+ scrollPos.Y) / 8)
	
	-- The tile the player is currently in
	-- self.flag = Flag(testX, testY)

	-- DrawRect(math.floor(testX) * 8, math.floor(testY) * 8, 8, 8, 5, DrawMode.SpriteBelow)


	if (Button(Buttons.A) or Button(Buttons.B)) and self.player.isgrounded then
		--launch the player upwards
		self.player.dy = -self.player.jumpvel

		if(self.jumpSound > - 1) then
			PlaySound(self.jumpSound, 3)
		end
	end
	--walk
	--

	if(currentFlag == KEY) then

		Tile(math.floor(center.X/8), math.floor(center.Y/8), -1)


	elseif(currentFlag == GEM) then
		
		Tile(math.floor(center.X/8), math.floor(center.Y/8), -1)

	elseif(currentFlag == DOOR_OPEN) then
	
	
	elseif(currentFlag == DOOR_OPEN) then

	elseif(currentFlag == LADDER) then

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

		
		-- 	self.player.dy = 0
		-- end

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
	DrawRect(math.floor(forward.X/8) * 8, math.floor(forward.Y/8) * 8, 8, 8, 8, DrawMode.SpriteBelow)

	--hit side walls
	--

	--check for walls in the
	--direction we are moving.
	
	-- if self.player.dx > 0 then xoffset = 7 end --moving right, check the right side.

	--look for a wall on either the left or right of the player
	--and at the players feet.
	--We divide by 8 to put the location in TileMap space (rather than
	--pixel space).
	-- self.flag = Flag((self.player.hitRect.X + xoffset) / 8, (self.player.hitRect.Y + 7) / 8)

	

	-- if(self.flag > -1) then
		
	-- 	print("flag", self.flag)
	-- end
	--We use flag 0 (solid black) to represent solid walls. This is controlled
	--by tilemap-flags.png.
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

	--hit floor
	--

	-- local lastisgrounded = self.player.isgrounded
	--assume they are floating
	--until we determine otherwise
	self.player.isgrounded = false

	--only check for floors when
	--moving downward
	if self.player.dy >= 0 then

		--
		-- offsetX = self.player.dir == true and 4 or 2
		-- offsetY = 8

		-- print("offsetX", offsetX, self.dir)

		-- testX = ((self.player.hitRect.X + offsetX + scrollPos.X) / 8)
		-- testY = ((self.player.hitRect.Y + offsetY+ scrollPos.Y) / 8)

		--check bottom center of the
		--player.
		local bottomFlag = Flag(math.floor(bottom.X/8), math.floor(bottom.Y/8))

		DrawRect(math.floor(bottom.X/8) * 8, math.floor(bottom.Y/8) * 8, 8, 8, 1, DrawMode.SpriteBelow)

		-- 	((self.player.hitRect.X + 4) + scrollPos.x) / 8,
		-- 	((self.player.hitRect.Y + 8) + scrollPos.y) / 8
		-- )

		

		--look for a solid tile
		if (bottomFlag == SPIKE) then

			print("Kill Player")


		elseif (bottomFlag == SOLID) then
			
			--place player on top of tile
			self.player.hitRect.Y = math.floor((self.player.hitRect.Y) / 8) * 8
			--halt velocity
			self.player.dy = 0

			--allow jumping again
			self.player.isgrounded = true
			
			-- DrawRect(math.floor(testX) * 8, math.floor(testY) * 8, 8, 8, 1, DrawMode.SpriteBelow)
		
		elseif (bottomFlag == LADDER and Button(Buttons.Down) == false ) then
			
		-- 		-- -place player on top of tile
		-- 		self.player.hitRect.Y = math.floor((self.player.hitRect.Y) / 8) * 8
		-- -- 		--halt velocity
				self.player.dy = 0
	
		-- -- 		--allow jumping again
				self.player.isgrounded = true
				
		-- 		DrawRect(math.floor(testX) * 8, math.floor(testY) * 8, 8, 8, 6, DrawMode.SpriteBelow)

			-- Make sure the player doesn't accumulate speed if in a falling loop
		elseif(self.player.dy > 5) then
			self.player.dy = 5
			-- end
			-- self.player.spriteID = 4
		else
			-- self.player.spriteID = 4
		end


		-- TODO Look for spikes when falling
	end

	--hit ceiling
	--


	--only check for ceilings when
	--moving up
	if self.player.dy < 0 then

		-- -- offsetX = 4
		-- offsetY = 2

		-- -- testX = ((self.player.hitRect.X + offsetX + scrollPos.X) / 8)
		-- testY = ((self.player.hitRect.Y + offsetY+ scrollPos.Y) / 8)
		
		local topFlag = Flag(math.floor(top.X/8), math.floor(top.Y/8))
		DrawRect(math.floor(top.X/8) * 8, math.floor(top.Y/8) * 8, 8, 8, 4, DrawMode.SpriteBelow)

		-- 	((self.player.hitRect.X + 4) + scrollPos.x) / 8,
		-- 	((self.player.hitRect.Y) + scrollPos.y) / 8
		-- )

		--self.flag = Flag((self.player.hitRect.X + 4) / 8, (self.player.hitRect.Y) / 8)
		--look for solid tile
		if (topFlag == SOLID) then
			--position self.player right below
			--ceiling
			self.player.hitRect.Y = math.floor((self.player.hitRect.Y + 8) / 8) * 8
			--halt upward velocity
			self.player.dy = 0

		end
	end

	-- Jumping
	if(self.player.dy < 0) then
		self.player.spriteID = 3
	
	-- Falling
	elseif(self.player.dy > 0) then
		self.player.spriteID = 4
	
	-- Moving
	elseif(self.player.dx ~= 0) then

		-- Test for the next animation frame
		if(self.player.time > self.player.delay) then

			-- Reset the time
			self.player.time = 0
			
			-- Increment the sprite
			self.player.spriteID = self.player.spriteID + 1

			-- Loop the sprite back to the first frame
			if(self.player.spriteID > 2) then
				self.player.spriteID = 1
			end

		end

	else

		-- Idle so use the first sprite
		self.player.spriteID = 1
	end

end

function MicroPlatformer:Draw()

	if(self.player.alive == false) then
		return
	end

	if(self.player.sprites ~= nil) then

		--draw the player, represented as sprite 1.
		DrawSprite(self.player.sprites[self.player.spriteID].Id, self.player.hitRect.X, self.player.hitRect.Y, self.player.dir, false, DrawMode.Sprite)--draw player
	end
end

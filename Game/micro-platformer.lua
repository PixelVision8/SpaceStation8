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
		x = 72,
		y = 16,
		w = 8,
		h = 8,
		--velocity
		dx = 0,
		dy = 0,

		dir = false,
		--is the player standing on
		--the ground. used to determine
		--if they can jump.
		isgrounded = false,
		spriteID = 1,
		--how fast the player is launched
		--into the air when jumping.
		jumpvel = 3.0,
		time = 0,
		delay = .1,
		sprites = MetaSprite("player").Sprites

	}
	
	-- _microPlatformer.bounds = DisplaySize()

	-- gravity per frame
	_microPlatformer.grav = 0.2

	_microPlatformer.flagID = 0

	-- stores the flag globally since it's used every frame
	_microPlatformer.flag = -1

	_microPlatformer.jumpSound = -1
	_microPlatformer.hitSound = -1

	return _microPlatformer

end

--called 60 times per second
function MicroPlatformer:Update(timeDelta)

	if(self.player.alive == false) then
		return
	end

	self.player.time = self.player.time + timeDelta



	--remember where we started
	local startx = self.player.x

	-- get the scroll position
	local scrollPos = ScrollPosition()

	--if on the ground and the
	--user presses a,b,or,up...

	if (Button(Buttons.Up) or Button(Buttons.A) or Button(Buttons.B))
	and self.player.isgrounded then
		--launch the player upwards
		self.player.dy = -self.player.jumpvel

		if(self.jumpSound > - 1) then
			PlaySound(self.jumpSound, 3)
		end



	end

	--walk
	--

	self.player.dx = 0
	if Button(Buttons.Left) then --left
		self.player.dx = -1
		self.player.dir = true
	end
	if Button(Buttons.Right) then --right
		self.player.dx = 1
		self.player.dir = false
	end

	--move the player left/right
	self.player.x = self.player.x + self.player.dx




	--hit side walls
	--

	--check for walls in the
	--direction we are moving.
	local xoffset = 0 --moving left check the left side of sprite.
	if self.player.dx > 0 then xoffset = 7 end --moving right, check the right side.

	--look for a wall on either the left or right of the player
	--and at the players feet.
	--We divide by 8 to put the location in TileMap space (rather than
	--pixel space).
	-- self.flag = Flag((self.player.x + xoffset) / 8, (self.player.y + 7) / 8)

	self.flag = Flag(
		((self.player.x + xoffset) + scrollPos.x) / 8,
		((self.player.y + 7) + scrollPos.y) / 8
	)
	--We use flag 0 (solid black) to represent solid walls. This is controlled
	--by tilemap-flags.png.
	if self.flag == self.flagID then
		--they hit a wall so move them
		--back to their original pos.
		--it should really move them to
		--the edge of the wall but this
		--mostly works and is simpler.
		self.player.x = startx
	end

	--accumulate gravity
	self.player.dy = self.player.dy + self.grav

	--apply gravity to the players position.
	self.player.y = self.player.y + self.player.dy

	--hit floor
	--

	local lastisgrounded = self.player.isgrounded
	--assume they are floating
	--until we determine otherwise
	self.player.isgrounded = false

	--only check for floors when
	--moving downward
	if self.player.dy >= 0 then

		--

		--check bottom center of the
		--player.
		self.flag = Flag(
			((self.player.x + 4) + scrollPos.x) / 8,
			((self.player.y + 8) + scrollPos.y) / 8
		)

		--look for a solid tile
		if self.flag == self.flagID then
			--place player on top of tile
			self.player.y = math.floor((self.player.y) / 8) * 8
			--halt velocity
			self.player.dy = 0

			--allow jumping again
			self.player.isgrounded = true


			-- Make sure the player doesn't accumulate speed if in a falling loop
		elseif(self.player.dy > 5) then
			self.player.dy = 5
			-- end
			-- self.player.spriteID = 4
		else
			-- self.player.spriteID = 4
		end
	end

	--hit ceiling
	--


	--only check for ceilings when
	--moving up
	if self.player.dy <= 0 then
		
		self.flag = Flag(
			((self.player.x + 4) + scrollPos.x) / 8,
			((self.player.y) + scrollPos.y) / 8
		)

		--self.flag = Flag((self.player.x + 4) / 8, (self.player.y) / 8)
		--look for solid tile
		if self.flag == self.flagID then
			--position self.player right below
			--ceiling
			self.player.y = math.floor((self.player.y + 8) / 8) * 8
			--halt upward velocity
			self.player.dy = 0

		end
	end


	if(self.player.dy < 0) then
		self.player.spriteID = 3
	elseif(self.player.dy > 0) then

		self.player.spriteID = 4
	elseif(self.player.dx ~= 0) then

		if(self.player.time > self.player.delay) then

			self.player.time = 0

			self.player.spriteID = self.player.spriteID + 1

			if(self.player.spriteID > 2) then
				self.player.spriteID = 1
			end

		end


	else
		self.player.spriteID = 1
	end

	-- if(self.player.dx ~= 0 and self.player.isgrounded == true) then
	--
	-- end

end

function MicroPlatformer:Draw()

	if(self.player.alive == false) then
		return
	end

	if(self.player.sprites ~= nil) then

		--draw the player, represented as sprite 1.
		DrawSprite(self.player.sprites[self.player.spriteID].Id, self.player.x, self.player.y, self.player.dir, false, DrawMode.Sprite)--draw player
	end
end

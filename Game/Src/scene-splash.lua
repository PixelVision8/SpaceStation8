--[[
    ## Space Station 8 `scene-splash.lua`

    Learn more about making Pixel Vision 8 games at http://docs.pixelvision8.com
]]--

-- We need to create a table to store all of the scene's functions.
SplashScene = {}
SplashScene.__index = SplashScene

local BLINK_TIMER = "blinktimer"

function SplashScene:Init()

  local _splash = {
    flickerVisible = false,
    selectLock = false,
    startLock = false
  }
  
  setmetatable(_splash, SplashScene) -- make Account handle lookup

  return _splash

end

function SplashScene:Reset()

  NewTimer(BLINK_TIMER, 500, 0)

  self.selectLock = Button(Buttons.Select, InputState.Down)
  self.startLock = Button(Buttons.Start, InputState.Down)

  -- Create UI
  DrawRect(0, Display().Y - 9, Display().X, 9, 0)
  
  DisplayMessage("SPACE STATION 8 BY JESSE FREEMAN", 2000, true, function() self:DisplayMapLoadMessage() end)

  -- It's important to note that we have to wrap out callback in another function. If we just passed in `self:DisplayMapLoadMessage()` we would lose the reference to the `self` table. By wrapping it in a function we can maintain the reference and ensure that it is triggered correctly.

end

-- We are going to use this function, which is called when the game's opening message disappears. This will kick off the logic to move from one map to another so the player can easily choose other maps they have created.
function SplashScene:DisplayMapLoadMessage()

  -- The `GetEntities()` function will return all of the items in a folder. We are going to use this to get all of the maps that are in the `/User/Maps/` path which we define in the `code.lua`'s `USER_MAP_PATH' constant.
  self.maps = GetEntities(USER_MAP_PATH)

  -- Let's save the total number of maps so we don't have to keep calling the `#` operator and calculate it every time we need to display the map count.
  self.mapCount = #self.maps

  -- We always want to start with the default map. We use the `table.insert()` function to add the default map path to the beginning of the list of map paths.
  table.insert(self.maps, 1, DEFAULT_MAP_PATH)

  -- If you are new to Lua or come from another programing language, its important to point out that arrays, which are indexed tables in Lua, start at 1. So by calling `table.insert()` and supplying `1` as the index, we are inserting the default map path at the beginning of the maps array.

  -- Now that the game is loaded, we can display the base text we'll use for instruction on how to start the game.
  DrawText("PRESS START FOR EDITOR OR DROP MAP HERE", 3, Display().Y- 9, DrawMode.TilemapCache, "medium", 2, -4)

  -- We'll also set the `flickerVisible` property to `true` so that the text will be highlighted on the next `Draw()` call.
  self.flickerVisible = true

  -- At this point, the game has fully loaded and the player is now able to pick a level and start the game.
  self.loaded = true

  -- Now we are going to call the `LoadMap()` function in order to load the first map in the list.
  self:LoadMap(1)

end

function SplashScene:LoadMap(id)

  -- We need to save the id that is passed in so we can iterate over it in the `LoadNextMap()` and `LoadPreviousMap()` functions.
  self.currentMap = id

  -- Now we need to convert the map path from a string into a workspace path.
  local mapPath = NewWorkspacePath(self.maps[id])

  -- It's important to call out that we are not doing any checks to make sure that the `id` is within the bounds of the maps array. We are just making the assumption that whatever calls this function passes in a valid id.

  

end


function SplashScene:Update(timeDelta)

  -- This is called a guard clause and we use these to make sure a function only gets called when a specif condition is met. In this case, we want to make sure the the initial title disappears before we give the player the option to start the game.
  if(self.loaded ~= true) then

    -- If the game`s `loaded` flag is not set, we want exit out of the update loop since the list of maps the player can pick from has not been loaded yet.
    return

  end
  
  if(TimerTriggered(BLINK_TIMER) == true) then

    self.flickerVisible = not self.flickerVisible
  end


  if(Button(Buttons.Start, InputState.Released) == true) then

    if(self.startLock == true) then

      self.startLock = false
    
    else

      -- Update global level value
      score = 0

      level = 1

      levelBonus = 0

      -- Switch to level scene
      SwitchScene(EDITOR)

    end

  end

end

function SplashScene:Draw()

  if(self.flickerVisible == true) then
    DrawText("      START FOR EDITOR    DROP MAP HERE", 3, Display().Y- 9, DrawMode.Sprite, "medium", 3, -4)
  end

end
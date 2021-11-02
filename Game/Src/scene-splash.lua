--[[
    ## Space Station 8 `scene-splash.lua`

    Learn more about making Pixel Vision 8 games at http://docs.pixelvision8.com
]]--

LoadScript("map-loader")

-- We need to create a table to store all of the scene's functions.
SplashScene = {}
SplashScene.__index = SplashScene

-- BLINK_TIMER = "blinktimer"
MAP_EXTENSION = ".png"


function SplashScene:Init()

  -- The splash screen will be responsible for loading a tilemap into memory. We'll create a new instance of the `MapLoader` so the scene has access to it.
  local _splash = {
    mapLoader = MapLoader:Init()
  }

  setmetatable(_splash, SplashScene) -- make Account handle lookup

  return _splash

end

function SplashScene:Reset()

  ClearTitle()
  ClearMessage()

  -- Reset the start lock so we can start the game again.
  self.startLock = false
  self.flickerVisible = false

  -- We are going to load all of the map files inside of the `USER_MAP_PATH` folder. In order to load them later on, we'll add each map to this table.
  self.maps = {}
  
  -- The `GetEntities()` function will return all of the items at a given path. We are going to use this to get all of the files that are in the `/User/Maps/` path which we define in the `code.lua`'s `USER_MAP_PATH' constant.
  local entities = GetEntities(USER_MAP_PATH)

  -- Now that we have all the items in the path, we need to loop through them and add them to the `maps` table.
  for i = 1, #entities do

    -- We need to make sure that we only add the files that end with the `.png` extension. So we can use the workspace path's `GetExtension()` to confirm it matches the default `.png` extension we defined in the `MAP_EXTENSION` constant.
    if(entities[i].GetExtension() == MAP_EXTENSION) then
      
      -- When we have a valid `.png` file, we need to add it to the `maps` table by using the `table.insert()` function.
      table.insert(self.maps, entities[i])

    end

  end

  -- Let's save the total number of maps so we don't have to keep calling the `#` operator and calculate it every time we need to display the map count.
  self.mapCount = #self.maps

  -- We always want to start with the default map. We use the `table.insert()` function to add the default map path to the beginning of the list of map paths.
  table.insert(self.maps, 1, DEFAULT_MAP_PATH)

  -- If you are new to Lua or come from another programing language, its important to point out that arrays, which are indexed tables in Lua, start at 1. So by calling `table.insert()` and supplying `1` as the index, we are inserting the default map path at the beginning of the maps array.

  -- Now we are going to call the `LoadMap()` function in order to load the first map in the list.
  self:LoadMap(1)

  -- Since hte `DisplayTitle()` function uses the `DrawColoredText()` API, we can pass in a color map for each character by making the `message` variable a table. The first item is the text for the message and the second is an array of colors offsets for each character.

  -- It's important to note that if there are not enough colors offsets for the characters, the last color offset will be used for the rest of the text.

  local title = MessageBuilder(
    {
      {"SPACE STATION 8 ", 3},
      {"BY ", 2},
      {"JESSE FREEMAN", 3}
    }
  )
  -- Now that the game is loaded, we can display the base text we'll use for instruction on how to start the game.
  DisplayTitle(title, 3000, true, function() self:OnLoad() end)

  local message = MessageBuilder(
    {
      {"A ", 2},
      {"MICRO PLATFORMER ", 3},
      {"FOR ", 2},
      {"PIXEL VISION 8", 3}
    }
  )

  DisplayMessage(message, -1)

end

-- This function is called when the message displaying the game's title disappears. We use this to tell the scene that it's fully loaded and ready to be start looking for player input to load a map or start the game.
function SplashScene:OnLoad()

  print("On Load")

  -- We set this `loaded` flag to true so the update function knows it can execute its code.
  self.loaded = true

  -- We call the `UpdateTitle()` function to redraw the title text at the top and bottom of the screen.
  self:UpdateTitle()

end

function SplashScene:LoadMap(id)

  -- We need to save the id that is passed in so we can iterate over it in the `LoadNextMap()` and `LoadPreviousMap()` functions.
  self.currentMap = id

  -- Now we need to convert the map path from a string into a workspace path.
  self.currentMapPath = NewWorkspacePath(self.maps[id])

  -- It's important to call out that we are not doing any checks to make sure that the `id` is within the bounds of the maps array. We are just making the assumption that whatever calls this function passes in a valid id.

  self.mapLoader:Load(self.currentMapPath)

  self:UpdateTitle()

end

function SplashScene:UpdateTitle()

  -- Clear any previous message
  ClearTitle()
  ClearMessage()

  -- Now its time to draw bars on the top and bottom of the screen for the UI. We'll use the `DrawRect()` API to draw a rectangle on the top starting at `0`,`0` which is the upper left corner of the screen. The bar will go across the screen so we use `Display().X` for the width, and `SpriteSize().Y` which is 8 pixels for the height.
  DrawRect(0, 0, Display().X, SpriteSize().Y-1)

  -- By default, the `DrawRect()` API draws a rectangle using color id `0` and uses `DrawMode.TilemapCache` which means that the rectangle will be drawn into the tilemap cache.

   DrawRect(0, Display().Y - SpriteSize().Y - 1, Display().X, SpriteSize().Y+1)


  -- Once we have the top bar drawn, we can do the same for the bottom. This time we are going to shift the `y` position to the bottom of the screen by using `Display().Y` and then subtract a single row of pixels via `SpriteSize().Y` plus `1` additional pixel to move the bar into the correct position.
  DrawRect(0, Display().Y - (SpriteSize().Y + 1), Display().X, (SpriteSize().Y + 1))

  -- The bottom bar on the screen will always be `9` pixels high due to the game's UI needing an extra row of pixels to center the icons and other UI elements vertically in the bar.

  local mapName = (self.currentMapPath == DEFAULT_MAP_PATH) and "DEFAULT" or string.upper(self.currentMapPath.EntityNameWithoutExtension:gsub(".spacestation8", ""))

  -- We are going to do some string formatting in the next couple of lines to create the title for the top of the screen. We'll be concatenating the back, map name, and next text to create a title that instructs the player which map is currently loaded and if they can move forward or backward through the list of maps we originally loaded when configuring the scene.

  -- Now we need to determine the maximum length of the map name that we can display. We'll do this by dividing the width of the screen, `Display().X`, by `4` which is the width of each character. Then we'll subtract the length of the back and next text which gives us the maximum amount of characters we can display for the map's name.
  local maxChars = (Display().X / 4)

  if(#mapName >= maxChars) then
    mapName = mapName:sub(1, maxChars-3) .. "..."
  end

  local title = MessageBuilder(
    {
      -- {backText, self.currentMap == 1 and 2 or 3},
      {mapName, 3},
      -- {nextText, self.currentMap == self.mapCount and 2 or 3},
    }
  )

  DisplayMessage(title, -1, true)

  local message = MessageBuilder
  (
    {
      {"MAP ", 2},
      {string.padLeft(tostring(self.currentMap), #tostring(self.mapCount), "0"), 3},
      {"/" .. self.mapCount, 2},
      {" START", 3},
      {"(", 1},
      {GetButtonMapping(Buttons.Start), 2},
      {") ", 1},
      {"PREVIOUS", self.currentMap == 1 and 1 or 3},
      {"(", 1},
      {GetButtonMapping(Buttons.Left), self.currentMap == 1 and 1 or 2},
      {") ", 1},
      {"NEXT", self.currentMap == self.mapCount and 1 or 3},
      {"(", 1},
      {GetButtonMapping(Buttons.Right), self.currentMap == self.mapCount and 1 or 2},
      {") ", 1},
    }
  )

  DisplayTitle(message, -1)

end

function SplashScene:NextMap()

  -- If the current map is the last map in the list, then we want to reset the map to the first map in the list.
  if(self.currentMap < self.mapCount) then
    self:LoadMap(self.currentMap + 1)
  end

end

function SplashScene:PreviousMap()

  -- If the current map is the first map in the list, then we want to reset the map to the last map in the list.
  if(self.currentMap > 1) then
    self:LoadMap(self.currentMap - 1)
  end

end

function SplashScene:Update(timeDelta)

  -- We need to create a guard clause here that checks to see if the `loaded` flag has been set to true. Since Lua allows us to test for a variable that has not been instantiated yet, we can simply look to see if `loaded` is set to anything but `true`, by default it will be `nil`, so we can exit out of the `Update()` function.
  if(self.loaded ~= true) then

    -- We'll exit out of the `Update()` function here.
    return

  end

  if(self.startLock == false) then
  
    -- Now we can check if the start button has been released. We'll use this to determine if we should change scenes.
    if(Button(Buttons.Start, InputState.Released) == true) then

      -- It's important to note that by default, calling the `Button()` API without an `InputState` it would default to `InputState.Pressed`. This would be fine if we were testing for the player's input since we'd want that to trigger when the button is pressed. However, if we were testing for UI input, we would want to check for the `Released` state.
      
        self.startLock = true
 
        local title = MessageBuilder
        (
          {
            {"CURRENT MAP SELECTED ", 2},
            {"EDIT", 3},
            {"(", 1},
            {GetButtonMapping(Buttons.A), 2},
            {") ", 1},
            {"BACK", 3},
            {"(", 1},
            {GetButtonMapping(Buttons.B), 2},
            {")", 1},
          }
        )

        DisplayTitle(title, -1, true)

        local message = MessageBuilder(
          {
            {"CONTINUING WILL ", 2},
            {"MAKE A COPY ", 3},
            {"OF THIS MAP", 2}
          }
        )

        DisplayMessage(message, -1)

    end

    if(Button(Buttons.Right, InputState.Released) == true) then

      self:NextMap()
      
    elseif(Button(Buttons.Left, InputState.Released) == true) then

      self:PreviousMap()

    end

  else

    if(Button(Buttons.A, InputState.Released) == true) then

      -- We can call the the `SwitchScene()` function we defined globally in the `code.lua` file. This will switch the scene to the game's level editor and use the currently loaded map to start with.
      SwitchScene(EDITOR)
      
    elseif(Button(Buttons.B, InputState.Released) == true) then
    
      self:UpdateTitle()
      self.startLock = false

    end

  end

end

function SplashScene:Draw()

  -- This is an empty function. There isn't anything that this scene should draw.

end
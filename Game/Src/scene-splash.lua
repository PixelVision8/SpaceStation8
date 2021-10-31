--[[
    ## Space Station 8 `scene-splash.lua`

    Learn more about making Pixel Vision 8 games at http://docs.pixelvision8.com
]]--

LoadScript("map-loader")

-- We need to create a table to store all of the scene's functions.
SplashScene = {}
SplashScene.__index = SplashScene

BLINK_TIMER = "blinktimer"
MAP_EXTENSION = ".png"


function SplashScene:Init()

  local _splash = {
    flickerVisible = false,
    startLock = false
  }

  -- The splash screen will be responsible for loading a tilemap into memory. We'll create a new instance of the `MapLoader` so the scene has access to it.
  _splash.mapLoader = MapLoader:Init()
  
  setmetatable(_splash, SplashScene) -- make Account handle lookup

  return _splash

end

function SplashScene:Reset()


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

  NewTimer(BLINK_TIMER, 500, 0)

  -- Now we are going to call the `LoadMap()` function in order to load the first map in the list.
  self:LoadMap(1)

  -- Since hte `DisplayMessage()` function uses the `DrawColoredText()` API, we can pass in a color map for each character by making the `message` variable a table. The first item is the text for the message and the second is an array of colors offsets for each character.

  -- It's important to note that if there are not enough colors offsets for the characters, the last color offset will be used for the rest of the text.

  DisplayMessage("SPACE STATION 8", 3000, true, function() self:OnLoad() end)

  DrawRect(0, Display().Y - 9, Display().X, 9)

  -- Now that the game is loaded, we can display the base text we'll use for instruction on how to start the game.
  DrawText("CREATED BY JESSE FREEMAN FOR LD JAM 49", 4, Display().Y- 9, DrawMode.TilemapCache, "medium", 2, -4)
  
end

function SplashScene:OnLoad()

  self.loaded = true





  self:UpdateTitle()
  -- DisplayMessage("Hello", -1, true)

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

  -- -- Clear any previous message
  ClearMessage()


  -- Now its time to draw bars on the top and bottom of the screen for the UI. We'll use the `DrawRect()` API to draw a rectangle on the top starting at `0`,`0` which is the upper left corner of the screen. The bar will go across the screen so we use `Display().X` for the width, and `SpriteSize().Y` which is 8 pixels for the height.
  DrawRect(0, 0, Display().X, SpriteSize().Y-1)

  -- By default, the `DrawRect()` API draws a rectangle using color id `0` and uses `DrawMode.TilemapCache` which means that the rectangle will be drawn into the tilemap cache.

  -- Once we have the top bar drawn, we can do the same for the bottom. This time we are going to shift the `y` position to the bottom of the screen by using `Display().Y` and then subtract a single row of pixels via `SpriteSize().Y` plus `1` additional pixel to move the bar into the correct position.
  DrawRect(0, Display().Y - (SpriteSize().Y + 1), Display().X, (SpriteSize().Y + 1))

  -- The bottom bar on the screen will always be `9` pixels high due to the game's UI needing an extra row of pixels to center the icons and other UI elements vertically in the bar.

  local mapName = (self.currentMapPath == DEFAULT_MAP_PATH) and "DEFAULT" or string.upper(self.currentMapPath.EntityNameWithoutExtension:gsub(".spacestation8", ""))

  -- We are going to do some string formatting in the next couple of lines to create the title for the top of the screen. We'll be concatenating the back, map name, and next text to create a title that instructs the player which map is currently loaded and if they can move forward or backward through the list of maps we originally loaded when configuring the scene.

  -- To create our title we'll need to start with the two variables that represent the back and next indicators in the title.
  local backText = "< BACK  "
  local nextText = " NEXT >"

  local optionChars = #backText + #nextText -- Should equal `14`

  -- Next, we need to create an array to store the color offsets for each of the title's characters. We'll fill this up with values as we loop through all of the characters in the title and determine which ones should be highlighted or disabled.
  local colorOffsets = {}

  -- Now we need to determine the maximum length of the map name that we can display. We'll do this by dividing the width of the screen, `Display().X`, by `4` which is the width of each character. Then we'll subtract the length of the back and next text which gives us the maximum amount of characters we can display for the map's name.
  local maxChars = (Display().X / 4) - optionChars - 1 -- Should equal `16`

  -- "< BACK "(7) [   empty space (30)  ] " NEXT >(7)"

  -- print("spaces", maxChars, #mapName)

  if(#mapName >= maxChars) then
    mapName = mapName:sub(1, maxChars-3) .. "..."
  end

  maxChars = maxChars - #mapName
  local emptyChars = math.floor(maxChars/2)

  print("pad", maxChars, emptyChars, #mapName)

  mapName = string.rep(" ", emptyChars) .. mapName .. string.rep(" ", maxChars - emptyChars)

  local leftHighlight = #backText
  local rightHighlight = #backText + #mapName

  local total = rightHighlight + #nextText

  for i = 1, total do
    
    local offsetValue = 3

    if(i < leftHighlight and self.currentMap == 1) then 

      offsetValue =  2

    elseif(i > rightHighlight and self.currentMap == self.mapCount) then
      
      offsetValue = 2

    end

    table.insert(colorOffsets, offsetValue)

  end

  -- Save the title incase we need to restore it later
  self.title = backText .. mapName .. nextText

  DisplayMessage({self.title, colorOffsets}, -1, true)

  DrawText("PRESS START FOR EDITOR OR DROP MAP HERE", 3, Display().Y- 9, DrawMode.TilemapCache, "medium", 2, -4)


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
  
    -- In order to have our start text blink, we need to keep track of the time since the last update. If there is a trigger, i.e. the timer has reached the designated time, we'll toggle the `blink` flag.
    if(TimerTriggered(BLINK_TIMER) == true) then

      -- In Lua we can flip a boolean value by using the `not` operator. Here we set the `flickerVisible` flag to the opposite of what it currently is.
      self.flickerVisible = not self.flickerVisible

    end

    -- Now we can check if the start button has been released. We'll use this to determine if we should change scenes.
    if(Button(Buttons.Start, InputState.Released) == true) then

      -- It's important to note that by default, calling the `Button()` API without an `InputState` it would default to `InputState.Pressed`. This would be fine if we were testing for the player's input since we'd want that to trigger when the button is pressed. However, if we were testing for UI input, we would want to check for the `Released` state.
      
        self.startLock = true
        self.flickerVisible = false

        DisplayMessage("PRESS [A] TO EDIT or [B] TO CANCEL", -1, true)

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

  if(self.flickerVisible == true) then
    DrawText("      START FOR EDITOR    DROP MAP HERE", 3, Display().Y- 9, DrawMode.Sprite, "medium", 3, -4)
  end

end
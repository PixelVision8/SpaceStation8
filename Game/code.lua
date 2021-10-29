--[[
  ## Space Station 8 `code.lua`
  
  This is the main `code.lua` file that runs  the entire game. It's responsible for loading in all the game code, managing the game's state, and loading/saving the map.

  Learn more about making Pixel Vision 8 games at http://docs.pixelvision8.com
]]--

-- We use the `LoadScript()` API to load each Lua file inside of the `/Game/Src/` directory. We can use this API to break down game logic into smaller, self-contained files.
LoadScript("scene-loader")
LoadScript("scene-splash")
LoadScript("scene-editor")
LoadScript("scene-draw")
LoadScript("scene-game")
LoadScript("message-bar")
LoadScript("utils")

-- Pixel Vision 8 will ignore scripts it's can't fine in the `/Game/Src/` directory which is helpful if you are just sketching out a game and where you want to put the logic.

-- These are the paths the game will need to use for loading maps and switching to the Settings Tool.
USER_LEVEL_PATH = NewWorkspacePath("/User/Maps/")
SETTINGS_TOOL_PATH = "/PixelVisionOS/Tools/Settings/"

-- The `NewWorkspacePath()` API allows us to create a path to the virtual filesystem Pixel Vision 8 sets up when it boots up. You can also add onto WorkspacePaths by calling `AppendFile()` or `AppendDirectory()` and it will return a new `WorkspacePath`. 

DEFAULT_MAP_PATH = NewWorkspacePath("/Game/map.spacestation8.png")
DEFAULT_SPRITE_PATH = NewWorkspacePath("/Game/sprites.png")
USER_MAP_PATH = NewWorkspacePath("/User/Maps/")
--[[
    Games can read files inside of their own directory. When a game is loaded into memory a virtual file system is created and mapped to the `/Game/` drive. This allows the game to read files from its own directory in a save way by constraining the file system to stay only in the `/Game/` directory. Once the game is loaded, you can access any file by using the `NewWorkspacePath()` API and passing in an absolute path to the file.
]]--


-- Since variable in Lua are global by default we can take advantage of this and create global constants to emulate an enum you'd find in other languages like C#. Here we define all of the game modes and set a int value to make it easier to switch between scenes by name instead of memorizing the Id.
LOADER, SPLASH, EDITOR, RUN, OVER = 1, 2, 3, 4, 2

-- We can also share Ids between scenes this way as well. Since the Splash and Over scenes are the same, we will use the some Id, `2`, for both scenes.

-- Here we set up several local variables to store the scenes, the active scene, and the active scene Id.
local scenes = nil
local activeScene = nil
local activeSceneId = 1

-- Each Lua script has it's own scope so we can hide these values from other scripts we load up by making them local.

-- The `Init()` function is part of the game's lifecycle and called a when a game starts. We'll use this function to configure the mask colors, background color, and scene instances.
function Init()

  -- By default, Pixel Vision 8's mask color is `#FF00FF` but we use `#937AC5` so our map png's look exactly how they would in the game.

  -- Change the background to `#937AC5` which is Id `2` so it matches the color in the map png file.
  BackgroundColor(2)
  
  -- Now we are going to create a table for each scene instance by calling the scene's Init() function.
  scenes = {
    LoaderScene:Init(),
    SplashScene:Init(),
    EditorScene:Init(),
    GameScene:Init(),
  }


  --[[
    
  If you try to run the code before you have a scene before you create the code for it, you will get an error. You can create the following files in your `/Game/Src/` folder as a place holder while we get the rest of the game working: `scene-loader.lua`, `scene-splash.lua`, `scene-editor.lua`, and `scene-game.lua`. 
  
  You can use the following template for each scene's code file, just replace the scene name with the scene you are creating.

  ```lua

  LoaderScene = {}
  LoaderScene.__index = LoaderScene

  function LoaderScene:Init()

    local _loader = {
    }

    setmetatable(_loader, LoaderScene)

    return _loader

  end

  ```

  ]]--
  -- Now that we have all of the scenes loaded into memory, we can call the `SwitchScene()` function and load the default scene.
  SwitchScene(LOADER)

  -- The loader scene is responsible for reading and parsing map data. We usually call this scene before any others in order to configure the level correctly before we edit or play it.

end

-- We use this function to prepare a new scene and run through all of the steps required to make sure the new scene is correctly reset and ready to go.
function SwitchScene(id)

  -- We want to save the active scene Id incase we need it later.
  activeSceneId = id

  -- Here we are saving the instance of the active scene so we can call `Update()` and `Draw()` on whichever scene is currently active.
  activeScene = scenes[activeSceneId]

  -- Finally, we need to reset the scene before it is loaded.
  activeScene:Reset()

  -- Since each scene is already instantiated, its `Init()` function won't be called again. We will use the `Reset()` function to restore the default values and state before loading it.

end

-- The `Update()` function is part of the game's life cycle. The engine calls `Update()` on every frame before drawing anything to the display. It accepts one argument, `timeDelta`, which is the difference in milliseconds since the last frame. You can use the `timeDelta` to sync animations and physics to the framerate incase it drops between frames.
function Update(timeDelta)

  -- The game's `Update()` function is where you'll want to do all your physics calculations, capture input changes, and any other logic that does not require rendering.

  -- First, we want to check for the escape key to be released on every frame.
  if(Key(Keys.Escape, InputState.Released)) then

    -- Before we load up the settings tool, let's make sure we save the state of the game.
    SaveState()
    
    -- We can load the Settings Tool, which is just another PV8 game, by calling the `LoadGame()` API and passing it a path as a string.
    LoadGame("/PixelVisionOS/Tools/SettingsTool/")

    -- It's also important to exit out of the Update() function so the scene doesn't update after we exit.
    return

  end

  -- Next, we need to check to see if there is an active scene before trying to update it. If one exists, we'll call `Update()` on the active scene and pass in the timeDelta.
  if(activeScene ~= nil) then
    activeScene:Update(timeDelta)
  end

  -- Finally, we call the `UpdateMessageBar()` function and pass in the timeDelta value.
  UpdateMenu(timeDelta)

end

-- The `Draw()` function is part of the game's life cycle. It is called after `Update()` and is where all of our draw calls should go.
function Draw()

  -- We can use the `RedrawDisplay()` method to clear the screen and copy the tilemap cache (which contains a pre-rendered tilemap) to the display.
  RedrawDisplay()

  -- Check to see if there is an active scene before trying to draw it.
  if(activeScene ~= nil) then

    -- Call the active scene's `Draw()` function.
    activeScene:Draw()
  
  end

  -- Redraw the menu by call its `DrawMenu()` function.
  DrawMenu()

end

-- The `SaveLevel()` function accepts a path and saves the current map to the `/Game/Maps/` directory.
function SaveMap(newPath)

  -- Test to see if there is a value for the `newPath`.
  if(newPath~= nil) then
    
    -- We need to save the last path so we know how to update the map if there are changes later on while editing it.
    lastImagePath = UniqueFilePath(newPath)
    
  end

  -- To save the map, we'll need to make a new Canvas first. We'll use the canvas to rebuild the map image, add text, and add the sprites at the bottom.  We'll create the canvas to match the size of the tilemap which is `160` x `152` pixels or `20` x `19` tiles.
  local mapCanvas = NewCanvas(TilemapSize().X * 8, TilemapSize().Y * 8)

  -- It's important to note that the tilemap is larger thant the display. This is because when it loads up the last two rows contain all of the sprites for the game. So when we go to save an image of the map, we want to make sure it has enough room for all tiles and sprites the game needs.
  
  -- Before we can copy the tiles to the canvas, we'll need to calculate how manu tiles there are by multiplying the tilemap size's `X` (Rows) by `Y` (Columns).
  local total = TilemapSize().X * TilemapSize().Y

  -- We'll use this loop to go through all of the tiles and copy them to the canvas.
  for i = 1, total do

    -- Use the game's `CalculatePosition()` function to return a point with the current tile's `X` and `Y` value based on the current loop's index.
    local pos = CalculatePosition(i-1, TilemapSize().X)

    -- Since Lua doesn't support `0` based arrays, we need to subtract `1` from the loop's index value, `i`, so we can get the correct position from the Game Chip's `CalculatePosition()` function.

    -- Here we are going to read the tile at the pos's `X`,`Y` value and save the `SpriteId` to a variable.
    local sprite = Tile(pos.X, pos.Y).SpriteId

    -- Now that we have the tile's position and sprite id we can draw it into the canvas.
    mapCanvas.DrawSprite(sprite, pos.X * 8, pos.Y * 8)

    -- The Canvas supports all of the same drawing calls at the Game Chip. Since the canvas doesn't use the same render model as the display, you don't have to supply a DrawMode. Every draw call is added to the canvas and when you access the Canvas's pixel data, it renders everything into a single layer.

  end

  -- We add instructions to the top of every map image that tells people where to download the game from. Here we set the message text and then draw it into the canvas.
  local message = "PLAY AT SPACESTATION8.DOWNLOAD"

  -- In order to center the text we'll need to calculate its `X` position by getting the Display's width, `X`, subtracting the width of the messages characters, and dividing it in half by multiplying everything by `.5`.
  local x = (Display().X - (#message * 4)) * .5

  -- Now that we have the message and the position, we can draw it onto the canvas via the `DrawText()` function.
  mapCanvas.DrawText(message, x, -1, "medium", 3, -4)

  -- The last thing we need to do is draw all of the sprites to the bottom of the map. Since we automatically create a meta sprite of them when the map is loaded up, we can just use `DrawMetaSprite()` instead of looping through all of them by hand.
  mapCanvas.DrawMetaSprite("tile-picker", 0, (TilemapSize().Y - 2) * 8)

  -- Now that we have everything drawn to the canvas we can copy the pixel data over to a new Image instance by calling `NewImage()`. We'll pass in the canvas's `width`, `height`, `pixels`, and the `colors` to use from memory.
  local tmpImage = NewImage(mapCanvas.Width, mapCanvas.Height, mapCanvas.GetPixels(), {MaskColor(),Color(0), Color(1), Color(2), Color(3)})

  -- Finally, we have everything we need to save the image to the user's map folder. We can call the `SaveImage()` function and pass it the path and image we just created.
  SaveImage(lastImagePath, tmpImage)

end


-- TODO THIS STILL NEEDS TO BE CLEANED UP

lastImagePath = NewWorkspacePath("/User/Levels/map.spacestation8.png")


-- The `OnLoad()` Function is responsible for loading a new map into memory. 
function OnLoadImage(value)

  if(activeSceneId == SPLASH or activeSceneId == LOADER) then
    
    value.RemapColors({MaskColor(),Color(0), Color(1), Color(2), Color(3)})

    scenes[LOADER].defaultMapImage = value

    SwitchScene(LOADER)

  end

end

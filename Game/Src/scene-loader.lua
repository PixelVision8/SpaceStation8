--[[
  ## Space Station 8 `scene-loader.lua`

  This is a special scene used to load and parse the game's tilemap png files. We call this before entering the an actual game scene so we can set up all of the game's tilemap data and meta sprites. Since Space Station 8 uses custom tilemap png files, we need to manually parse the pixel data sprite by sprite and put them into memory.

  Learn more about making Pixel Vision 8 games at http://docs.pixelvision8.com
]]--

-- We need to create a table to store all of the scene's functions.
LoaderScene = {}
LoaderScene.__index = LoaderScene

-- This is the constructor for the loader scene. We are going to use it to create a table and store the event data in it.
function LoaderScene:Init()

  -- We'll start by creating a table to store our scene's data. We'll store the path to the default map which is at the root of the game's folder.
  local _loader = {
    imagePath = DEFAULT_MAP_PATH,
  }

  -- You may be wondering why are we setting this to the `DEFAULT_MAP_PATH` constant we defined earlier? Well, we plan on using this image path to load custom tilemaps the player creates. When we first initialize the load scene, we'll set this to the default map path but later on, we'll change this path while all of the other tilemap loading and parsing logic remains the same.

  -- We want to change the mask color so when we parse image so wherever it see's `#937AC5`, the parser will ignore that pixel including in the sprites at the bottom of the map png file.
  local mask = MaskColor(Color(2))

  -- When calling an API like `MaskColor()` and pass in a color id, it will return the hex for the color it was changed to. If we called this API without passing in a color id, it would return the current mask color hex. Now we can reference `mask` later on when we need to use the mask color instead of having to call the API again.

  -- Now that we have a path to the default map file, we need to load it into memory. We'll use the `ReadImage()` API to do this. We'll pass in the path to the image and a mask color that will determine what color pixels are considered transparent. Here we are using the second color, `#937AC5`, which we defined earlier as the transparent mask.
  _loader.defaultMapImage = ReadImage(_loader.imagePath, mask)

  -- It's important to note that normally, the transparent mask is #FF00FF, which is magenta. Since our game is going to use a custom map template formate which we want to look like a screenshot of the level itself, we are going to make the default background color and transparent mask the same. In  this case, wherever the image parser see's `#937AC5` it will ignore that pixel including in the sprites at the bottom of the map png file.

  -- To make this a bit easier to read, we are going to add the color map array to the loader table here. This is an array of colors that we can use remap image colors to the colors in the `ColorChip`'s memory.
  _loader.colorMap = {
    mask,
    Color(0), -- #2D1B2E
    Color(1), -- #574B67
    Color(2), -- #937AC5 (mask)
    Color(3)  -- #F9F4EA
  }

  -- Once we have the image loaded, we need to remap the colors to match the correct order in the `Color Chip` memory. We do this by calling the image's `RemapColors()` function and pass in a table with the correct color order starting with the mask color first.
  _loader.defaultMapImage.RemapColors(_loader.colorMap)

  -- The `RemapColors()` function works by looking at the colors in the image and reordering them based on the new colors passed in. The first color is always the mask and then it should go in order of the colors in the `Color Chip` memory. This only works if the image uses the same colors as the `Color Chip` unless you supply your own hex colors in order to manually to map them to existing colors in the memory'. You can always access the image's color's via the `.Colors` property which returns an array of hex colors in the order they were parsed.

  -- With the scene's data configured, we need to register the instance of the scene with the table that has all of the functions.
  setmetatable(_loader, LoaderScene) -- make Account handle lookup

  -- Finally we can return the instance of the scene.
  return _loader

end

-- We use the `Reset()` function to reset the scene's data. We need to use do this here because when we transition between scenes, the game attempts to reuse each one. If we don't reset all the values here it will start back up in the the previous state.
function LoaderScene:Reset()

  -- To be safe, we are going to clear the screen by calling the `DrawRect` API with the display's dimensions and background color. This should remove any remnants of the previous scene or map form the tilemap cache.
  DrawRect(0, 0, Display().X, Display().Y, BackgroundColor())

  -- The `DrawRect()` API is used to draw a rectangle on the screen. By default, it will draw the rectangle into the tilemap cache which is where a snapshot of the tilemap's pixel data is stored to help speed up rendering. You can learn more about the `DrawRect()` API at https://github.com/PixelVision8/PixelVision8/wiki/draw-rect

  
  -- In order for use to correctly parse the map image, we need to know the size of the tilemap. This is the number of tiles in the X and Y direction. We can get this from the image's `.Width` and `.Height` properties and divide by the size of the a sprite.
  local cols = math.floor( self.defaultMapImage.Width / SpriteSize().X )
  local rows = math.floor( self.defaultMapImage.Height / SpriteSize().Y )

  -- Sprites in Pixel Vision 8 are set to 8x8 pixels by default. We can use the `SpriteSize()` API to get the size of a sprite instead of having to hard code it. Currently, there is no way to change this but it may be different in future versions of Pixel Vision 8.

  -- Now we need to calculate how many rows will be reserved for sprites.
  local spriteRows = 2 * SpriteSize().Y

  -- In the Space Station 8 map template the first 17 rows are reserved for the tilemap and the last two rows are reserved for the sprites. We'll be manually reading the sprites after setting everything else up.

  -- Now we need to make sure that the image is the correct size. We do this by testing that the number of columns and rows match the number of tiles in our template.
  if(cols < 20 or rows < 17) then

    -- If the image is not the correct size, we need to display an error message.
    DrawText("There was an error loading the image.", 4, 0, DrawMode.TilemapCache, "medium", 3, -4)
    DrawText("Please make sure it's 160 x 136 pixels.", 4, 8, DrawMode.TilemapCache, "medium", 3, -4)

    -- Finally we return out of the reset function so the game will freeze until the user supplies a map that is the correct size or restarts the game.
    return

  end

  -- Now we are ready to parse the image but first we are going to need to reformat it to match out template where rows 0 - 16 are the tiles for the background and rows 17 - 20 are the tiles for the sprites. You can see here we are calling the `NewCanvas()` API with the display's width and height plus one extra row for our sprites.
  local mapImage = NewCanvas(Display().X, Display().Y + SpriteSize().Y)

  --[[
    While the Pixel Vision 8's `ImageData` class has some basic functions for manipulating images, it's not the most efficient way to work with images. We can use the `NewCanvas()` API to create a new canvas, copy over the image's pixel data, and continue to manipulate the pixels from there.

    One of the advantages of the Pixel Vision 8's canvas is the ability to draw sprites and text to it. You also get access to a full set of drawing APIs like creating lines, rectangles, and ovals. For this game, we'll be using the canvas's sprite and text functions to create the tilemap itself and later on, save the one the player creates in the game.
  ]]--

  -- The first thing we need to do is copy over the map's pixel data to the canvas we just created. 
  mapImage.SetPixels(0, 0, self.defaultMapImage.Width, self.defaultMapImage.Height, self.defaultMapImage.GetPixels())

  -- The first thing we need to do is load up the default sprites in a similar way to how we did with the map. We'll use the `ReadImage()` and pass in the path to the sprites at `/Game/sprites.png/' and the mask color.
  local defaultSprites = ReadImage(NewWorkspacePath(DEFAULT_SPRITE_PATH))

  -- Once the sprites image is loaded, we need to remap the colors to match the correct order in the `Color Chip` memory.
  defaultSprites.RemapColors(self.colorMap)

  -- With the colors correctly mapped, we can copy the image data to the `mapImage` canvas. To do this, we'll call the canvas's `SetPixels()` function and pass in the image's pixel data.  We also want to offset the pixel data so we draw it at the bottom of the canvas. That's why we have `X` set to `0` and `Y` set to the image's `Height` minus the `spriteRows` which is `16` pixels which is two rows of sprites.
  mapImage.SetPixels(0, mapImage.Height - spriteRows, defaultSprites.Width, defaultSprites.Height, defaultSprites.GetPixels())

  --[[
    While the `SetPixels()` function is used to copy the image data to the canvas the `GetPixels()` function is used to retrieve pixel data. Since the last argument of `SetPixels()` requires pixel data, we call `GetPixels()` on the sprite image we previously loaded and feed it into the canvas.

    One thing to point out is that we are making an assumption that the `sprites.png` file will be the width of the `mapImage` canvas, which should be `160`, and `16` pixels high. That is why we can blindly call `GetPixels()` without supplying a `width` or `height` argument. If you plan on modifying this template format, you'll need to take this into consideration because without a check on the `sprite.png` file's size, you could get an error.
  ]]--

  -- We can call the `ClearTilemap()` API to clear the `TilemapChip` memory. This will clear out all the tile data and reset it to the default values.
  ClearTilemap()

  -- Rebuild the Tilemap by hand
  local totalTiles = (mapImage.Width/SpriteSize().X) * (mapImage.Height/SpriteSize().Y)

  -- We need to calculate position where the tiles end and the sprites begin. We'll use this to determine if we are currently parsing a sprite or tile.
  local spriteOffset = cols * rows

  -- Now we need to go through all of the tiles in the `mapImage` canvas and convert them into sprites and tiles. We'll do this by looping backwards through the `mapImage` and determining if the 8x8 pixel block should be a copied to the `SpriteChip` or the `TilemapChip`.
  for i = totalTiles, 1, -1 do
    
    -- Normally you would loop through an array like `for i = 1, 10, 1 do` but since we are looping backwards, we use `for i = totalTiles, 0, -1`. This works because we start at the last number, subtract `1` on each loop until we reach `0`. While this adds a bit more complexity to the loop, it will allow us to use a single for statement to find the sprites and tiles.
    
    -- Find the source column and row
    local pos = CalculatePosition(i-1, cols)

    -- -- Copy over the pixel data to the canvas
    local pixels = mapImage.GetPixels(pos.X * 8, pos.Y * 8, 8, 8)

    -- We need to determine if the current pixel block should be a sprite or a tile. We'll do this by checking if the current index is less than the sprite offset.
    if(i > spriteOffset) then

      -- At this point we know we are dealing with a sprite so we need to remap the current loop index to the 'SpriteChip' memory. We can do this by subtracting the sprite offset from the current `i` value it reverses the index putting the last sprite in the first index.
      local spriteId = i - spriteOffset - 1

      --[[
       There is a lot going on here so let's dig a bit deeper into why we need to recalculate the sprite`s id. We need to make sure that sprites are added to the `SpriteChip` in the correct order. The first sprite should be added to the first index and the last sprite should be added to the last index.
       
       If we use the `i` value as the sprite id, we'll get the sprites in the wrong order since we are looping backward. By subtracting the sprite offset from the current `i` value we reverse the index and we can use the `i` value as the sprite id. The only thing left to do is subtract `1` from the sprite id since the sprite id is zero based.
      ]]--
      
      -- Now we can add the sprite to the `SpriteChip` memory. We'll call the `Sprite()` API and pass in the sprite id and pixel data we retrieved at the beginning of the current loop iteration.
      Sprite(spriteId, pixels)

    -- If we are past the sprite are of the map, we can assume that all other 8x8 sections of the `mapImage` are tiles which we need to handle differently than sprites.
    else
      
      -- We can use the `FineSprite()` API to see if a given pixel data array exists in the `SpriteChip` memory. We can use that id to tell the tile at the current postilion what sprite to use.
      Tile(pos.X, pos.Y, FindSprite(pixels))

      -- The `FindSprite()` API will return `-1` if there is no matching pixel data in memory. Setting a tile's `spriteId` to `-1` will clear the tile. Since we can guarantee that the `FindSprite()` API will return a valid sprite id, we can use that to set the tile's sprite id or clear it if the `FindSprite()` API returns `-1`.

    end
    
  end

  -- TODO need to clean this up so it's not always saving
  -- SaveMap(NewWorkspacePath(USER_MAP_PATH.AppendFile(self.imagePath.EntityName)))

  -- Now that the tilemap has been correctly parsed and loaded into memory, we can call the `SwitchScene()` function to load the `SPLASH` scene.
  SwitchScene(SPLASH)

end
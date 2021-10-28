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
    flickerVisible = true,
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
  

  -- DrawText("SPACE STATION 8 BY JESSE FREEMAN", 20, -1, DrawMode.TilemapCache, "medium", 3, -4)
  DrawText("PRESS START FOR EDITOR OR DROP MAP HERE", 3, Display().Y- 9, DrawMode.TilemapCache, "medium", 2, -4)

  -- print("messageBar", messageBar)

  DisplayMessage("SPACE STATION 8 BY JESSE FREEMAN", 2000)
  

end

function SplashScene:Update(timeDelta)

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
--[[
  Pixel Vision 8 - ReaperBoy v2
  Copyright (C) 2017, Pixel Vision 8 (http://pixelvision8.com)
  Created by Jesse Freeman (@jessefreeman)

  Licensed under the Microsoft Public License (MS-PL) License.

  Learn more about making Pixel Vision 8 games at http://pixelvision8.com
]]--

-- Splash Scene
SplashScene = {}
SplashScene.__index = SplashScene

function SplashScene:Init()

  local _splash = {
    flickerTime = 0,
    flickerDelay = 400,
    flickerVisible = true,
    selectLock = false,
    startLock = false
  }

  setmetatable(_splash, SplashScene) -- make Account handle lookup

  return _splash

end

function SplashScene:Reset()

  print("Create new image")



  self.selectLock = Button(Buttons.Select, InputState.Down)
  self.startLock = Button(Buttons.Start, InputState.Down)

  -- Create UI
  DrawRect(0, 0, Display().X, 7, 0)
  DrawRect(0, Display().Y - 8, Display().X, 8, 0)
  

  DrawText("SPACE STATION 8 BY JESSE FREEMAN", 20, -1, DrawMode.TilemapCache, "medium", 3, -4)
  DrawText("PRESS START FOR EDITOR OR DROP MAP HERE", 3, Display().Y- 9, DrawMode.TilemapCache, "medium", 2, -4)

end

function SplashScene:Update(timeDelta)

  -- Universal flicker timer
  self.flickerTime = self.flickerTime + timeDelta

  if(self.flickerTime > self.flickerDelay) then
    self.flickerTime = 0
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

      -- Change song
      PlayPatterns({1}, true)

    end

  end

end

function SplashScene:Draw()

  -- if(Button(Buttons.Start)) then
    
  --   for i = 1, 96 do
    
  --     local pos = CalculatePosition(i-1, 20)
  --     local id = i-1
  --     DrawText(tostring((id < 10 and "0" or "") .. id), pos.X * 8, pos.Y * 8, DrawMode.Sprite, "medium", 3, -4)

  --   end

  -- end

  if(self.flickerVisible == true) then
    DrawText("      START FOR EDITOR    DROP MAP HERE", 3, Display().Y- 9, DrawMode.Sprite, "medium", 3, -4)
  end
  

end

function SplashScene:SaveState()
  
  return "GameScene State"

end

function SplashScene:RestoreState(value)
  
  print("Restore state", state)

end

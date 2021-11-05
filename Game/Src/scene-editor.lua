--[[
  ## Space Station 8 `scene-self.lua`

  
  
  Learn more about making Pixel Vision 8 games at http://docs.pixelvision8.com
]]--


MODE_DRAW, MODE_OPTIONS, MODE_RENAME, MODE_STARTING = 1, 2, 3, 4

-- We need to define these global modes before we requite our plugins or they will not have access to these

local brushPlugin = require "scene-editor-brush"
local optionsPlugin = require "scene-editor-options"
local mousePlugin = require "scene-editor-mouse"

-- We need to create a table to store all of the scene's functions.
EditorScene = {}
EditorScene.__index = EditorScene

function EditorScene:Init()

  local _editor = {
    currentTile = 0,
    altTile = false,
    tileId = 0,
    spriteId = 0
  }
  
  _editor.tiles = {
    {00, 00}, -- Empty
    {01, 20}, -- Door
    {02, 21}, -- Player
    {03, 22}, -- Enemy
    {04, 04}, -- Platform Left
    {05, 05}, -- Platform Center
    {06, 06}, -- Platform Right
    {07, 07}, -- Platform
    {08, 28}, -- Platform Edge (Should remove?)
    {09, 29}, -- Spike
    {10, 30}, -- Arrow Up
    {11, 31}, -- Arrow Right
    {12, 32}, -- Wall
    {13, 33}, -- Switch
    {14, 14}, -- Ladder
    {15, 15}, -- Key
    {16, 16}, -- GEM
    {17, 17}, -- Pillar Bottom
    {18, 18}, -- Pillar Middle
    {19, 19}, -- Pillar Top
  }


  -- This is a global table that we can use for plugins to register themselves with the self. When the scene is instantiated, we'll map this table to the scene's `plugins` table.
  _editor.plugins = {
    brushPlugin,
    mousePlugin,
    optionsPlugin,
  }

  _editor.totalPlugins = #_editor.plugins

  _editor.mode = MODE_DRAW

  setmetatable(_editor, EditorScene) -- make Account handle lookup

  return _editor

end

function EditorScene:Reset()

  self.mode = MODE_DRAW

  self.currentTile = 0
  self.startTimer = -1

  self:DrawEditorUI()

  -- NewTimer(INPUT_LOCK_TIMER, 100)

end

function EditorScene:DrawEditorUI()

  -- Create UI
  DrawRect(0, 0, Display().X, 7, 0)
  DrawRect(0, Display().Y - 8, Display().X, 8, 2)


  local title = MessageBuilder
  (
    {
      {"DRAW", 3},
      {"(", 1},
      {GetButtonMapping(Buttons.A), 2},
      {") ", 1},
      {"FLIP", 3},
      {"(", 1},
      {GetButtonMapping(Buttons.B), 2},
      {") ", 1},
      {"RUN", 3},
      {"(", 1},
      {GetButtonMapping(Buttons.Start), 2},
      {") ", 1},
      {"OPTIONS", 3},
      {"(", 1},
      {GetButtonMapping(Buttons.Select), 2},
      {")", 1},
    }
  )

  DisplayTitle(title, -1)

  DrawMetaSprite("tile-picker", 0, 17, false, false, DrawMode.Tile)

end



function EditorScene:FlipTile()

  self.altTile = not self.altTile

end

function EditorScene:DrawTile(column, row)

  local value = self.spriteId > 0 and self.spriteId or -1

  if (Tile(column, row).SpriteId ~= value) then
    
    Tile(column, row, value)

  end

end

function EditorScene:SelectTile(id)

  self.currentTile = id
  self.altTile = false
  
end



function EditorScene:Update(timeDelta)

  if(self.mode == MODE_DRAW and Button(Buttons.Start, InputState.Released)) then

    self.mode = MODE_STARTING

    local title = MessageBuilder
    (
      {
        
        {"PLAY", 3},
        {"(", 1},
        {GetButtonMapping(Buttons.A), 2},
        {") ", 1},
        {"BACK", 3},
        {"(", 1},
        {GetButtonMapping(Buttons.B), 2},
        {") ", 1},
      }
    )

    DisplayTitle(title, -1)

    local title = MessageBuilder
    (
      {
        {"PLAYING WILL AUTOMATICALLY ", 2},
        {"SAVE THE MAP", 3},
      }
    )

    DisplayMessage(title, -1)

  end

  if(self.mode == MODE_STARTING) then

    if(Button(Buttons.A, InputState.Released)) then

      mapLoader:Save()

      SwitchScene(RUN)

    elseif(Button(Buttons.B, InputState.Released)) then

      self.mode = MODE_DRAW

      self:DrawEditorUI()

    end
  
  else

    self:UsePlugins("Update", timeDelta)

    self.tileId = self.currentTile + 1
    self.selectionX = (self.tileId - 1) * 8

    self.spriteId = self.tiles[self.currentTile + 1][self.altTile == false and 1 or 2]

  end

end

function EditorScene:Draw()

  self:UsePlugins("Draw")

end

function EditorScene:UsePlugins(action, timeDelta)
  
  for i = 1, self.totalPlugins do

    local plugin = self.plugins[i]

    if(plugin ~= nil and plugin[action] ~= nil) then
      plugin[action](self, timeDelta)
    end
   
  end

end
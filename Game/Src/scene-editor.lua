--[[
  ## Space Station 8 `scene-editor.lua`

  
  
  Learn more about making Pixel Vision 8 games at http://docs.pixelvision8.com
]]--


MODE_DRAW, MODE_OPTIONS, MODE_RENAME = 1, 2, 3

-- We need to define these global modes before we requite our plugins or they will not have access to these

local brushPlugin = require "editor-plugin-brush"
local optionsPlugin = require "editor-plugin-options"
local mousePlugin = require "editor-plugin-mouse"

-- We need to create a table to store all of the scene's functions.
EditorScene = {}
EditorScene.__index = EditorScene

-- This is a global table that we can use for plugins to register themselves with the editor. When the scene is instantiated, we'll map this table to the scene's `plugins` table.
_G["editorPlugins"] = {}

-- We need to load the plugins after the Editor scene has been created so we can attach the plugin function to the scene's scope.
-- LoadScript("editor-plugin-cursor")
-- LoadScript("editor-plugin-options")




INPUT_LOCK_TIMER = "InputLockTimer"
INPUT_TIMER = "InputTimer"

function EditorScene:Init()

  local _editor = {
    -- brushPos = NewPoint(0, 0),
    -- cursorBounds = NewRect(0, 1, (Display().C) - 1, (Display().R) - 3),
    currentTile = 0,
    
    -- blink = false,
    altTile = false,
    tileId = 0,
    -- selectionX = 0,
    spriteId = 0,

  }

  -- Look for editor plugins
  _editor.plugins = {
    brushPlugin,
    optionsPlugin,
    -- mousePlugin
  }

  _editor.totalPlugins = #_editor.plugins

  NewTimer(INPUT_TIMER, 100)

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

  _editor.mode = MODE_DRAW

  setmetatable(_editor, EditorScene) -- make Account handle lookup

  return _editor

end

function EditorScene:Reset()

  self.mode = MODE_DRAW

  self.currentTile = 0
  self.startTimer = -1

  self:DrawEditorUI()

  NewTimer(INPUT_LOCK_TIMER, 100)

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
      {"NEXT", 3},
      {"(", 1},
      {GetButtonMapping(Buttons.Select), 2},
      {") ", 1},
      {"OPTIONS", 3},
      {"(", 1},
      {GetButtonMapping(Buttons.Start), 2},
      {")", 1},
    }
  )

  DisplayTitle(title, -1)

  DrawMetaSprite("tile-picker", 0, 17, false, false, DrawMode.Tile)

end

function EditorScene:Update(timeDelta)

  for i = 1, self.totalPlugins do

    local plugin = self.plugins[i]

    if(plugin ~= nil and plugin.Update ~= nil) then
      plugin.Update(self, timeDelta)
    end
    
  end

end

function EditorScene:FlipTile()

  self.altTile = not self.altTile

end

function EditorScene:DrawTile(x, y)

  local value = self.spriteId > 0 and self.spriteId or -1

  if (Tile(x, y).SpriteId ~= value) then
    
    Tile(x, y, value)

  end

end

function EditorScene:SelectTile(id)

  self.currentTile = id
  self.altTile = false
  
end

function EditorScene:Draw()

  for i = 1, self.totalPlugins do

    local plugin = self.plugins[i]

    if(plugin ~= nil and plugin.Draw ~= nil) then
      plugin.Draw(self, timeDelta)
    end
    
  end

end
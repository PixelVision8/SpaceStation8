--
-- Copyright (c) 2017, Jesse Freeman. All rights reserved.
--
-- Licensed under the Microsoft Public License (MS-PL) License.
-- See LICENSE file in the project root for full license information.
--
-- Contributors
-- --------------------------------------------------------
-- This is the official list of Pixel Vision 8 contributors:
--
-- Jesse Freeman - @JesseFreeman
-- Christina-Antoinette Neofotistou - @CastPixel
-- Christer Kaitila - @McFunkypants
-- Pedro Medeiros - @saint11
-- Shawn Rakowski - @shwany
--

local patterns = {
  hex = '%x',
  number = '%d',
  file = '[_%-%w ]',
  keys = '%a',
  note = '[A-G#]',
  variable = '[%w]'
}

function EditorUI:CreateInputField(rect, text, toolTip, pattern, font, colorOffset, spacing)

  -- Set the edit flag if it's not yet set
  if(self.editingInputField == nil) then
    self.editingInputField = false
  end

  -- If no hight is provided, simply make the height one row high
  if(rect.h == nil) then
    rect.h = self.spriteSize.y
  end
  
  font = font or "large"
  spacing = spacing or 0
  
  -- font = font or "medium"
  -- spacing = spacing or -4
  -- colorOffset = colorOffset or 15

  local data = self:CreateTextEditor(rect, text, toolTip, font, colorOffset, spacing)

  -- data.name = "InputArea" .. data.name
  data.drawMode = DrawMode.Tile
  data.editing = false
  data.onValidate = nil
  data.toolTip = toolTip
  data.onAction = nil
  data.scrollValue = {h = 0, v = 0}
  data.totalLines = 0
  data.maxLineWidth = 0

  -- if(text ~= nil) then
  --   self:ChangeInputArea(data, text)
  -- end

  -- Create a unique name by removing the InputArea string from the data's name
  data.name = "InputField" .. data.name:sub(10, - 1)

  data.multiline = data.tiles.h > 1
  data.maxLines = data.tiles.h
  data.endOfLineOffset = 1
  data.nextField = nil
  data.previousField = nil
  data.clearValue = ""
  data.clearOnEnter = false
  data.allowEmptyString = false
  data.forceCase = nil -- Accepts nil, upper and lower
  data.colorize = false

  data.pattern = pattern

  -- Remap return
  data.keymap["return"] = function(targetData)
    --print("Submit Field Value")

    -- TODO need to validate the value before saving

    -- Save value to text property
    data.text = self:TextEditorExport(targetData)

    -- Stop editing via the input field's custom method
    self:EditTextEditor(data, false)

  end

  -- Remap up to home
  data.keymap["up"] = data.keymap["home"]

  -- Remap down to end
  data.keymap["down"] = data.keymap["end"]

  data.captureInput = function(targetData)

    return self:ValidateInputFieldText(targetData, InputString())

  end

  data.onEdit = function(targetData, value)

    -- print("Input Field Edit", value)
    self:OnEditTextInputField(targetData, value)

  end

  -- We want to route the default text through ChangeInputField
  if(text ~= nil) then
    self:ChangeInputField(data, text)
  end

  return data

end

function EditorUI:ValidateInputFieldText(targetData, inputString, pattern, forceCase)

  local outputString = ""

  pattern = pattern ~= nil and patterns[pattern] or patterns[targetData.pattern]
  forceCase = targetData ~= nil and targetData.forceCase or forceCase

  for char in inputString:gmatch"." do

    if(pattern ~= nil) then
      char = string.match(char, pattern)
    end

    if(char ~= nil) then

      if(forceCase ~= nil) then
        char = string[forceCase](char)
      end

      -- Text to see if the input field is a single character and clear it
      if(targetData ~= nil and targetData.tiles.w == 1) then
        targetData.buffer[1] = char
      else
        outputString = outputString .. char
      end

    end

  end

  return outputString

end

function EditorUI:OnEditTextInputField(data, value)

  -- Test to see if we are entering edit mode
  if(value == true) then

    data.previousValue = data.buffer[1]

    -- Clear the buffer if the input field is only 1 character
    if(data.tiles.w == 1) then
      data.buffer[1] = ""
    else
      self:TextEditorSelectAll(data)
    end

  elseif(value == false and data.editing == true) then

    -- If empty, restore the previous value
    if(data.buffer[1] == "") then
      data.buffer[1] = data.previousValue
    end

    self:TextEditorGotoLineStart(data)
    -- If we were just editing, force the buffer back through the valdation
    self:ChangeInputField(data, data.buffer[1], false)
  end

  -- Track if an input field is being editing at the UI level
  self.editingInputField = value

end

function EditorUI:UpdateInputField(data)

  -- Test to see if the enabled state has changed
  if(data.lastEnabledState ~= data.enabled) then
    -- print(data.name, "Enabled state changed", data.enabled)

    -- Save the new state for the next frame
    data.lastEnabledState = data.enabled

    -- Invalidate the display
    self:TextEditorInvalidateBuffer(data)
  end

  self:TextEditorUpdate(data, self.timeDelta)

  if(data.editing and data.sxs == nil) then

    if(#data.buffer[1] >= data.tiles.w) then
      self:EditTextEditor(data, false)
    end

  end

end


function EditorUI:ChangeInputField(data, text, trigger)
  -- Input fields need to process the text before setting it

  -- print(data.name, "ChangeInputField", text)

  -- Look for any custom validation
  if(data.onValidate ~= nil) then
    text = data.onValidate(text)
  end

  -- Make sure the field is within number range if a number
  if(data.pattern == "number") then

    -- Make sure that the text is always set to zero if it's not valid
    if(text == nil) then
      text = ""
    end

    if(data.allowEmptyString == false and text == "") then
      text = "0"
    end

    if(data.allowEmptyString == false) then
      -- Convert text to a number
      local value = tonumber(text)

      -- TODO need to add logic for handling negative numbers
      -- update the text var with the new value
      if(value < 0) then
        -- negative numbers are not valid so just replace with -
        text = string.lpad(tostring(""), data.tiles.w, "-")
      else

        -- make sure that the value is above the minimum allowed value
        if(data.min ~= nil) then
          if(value < data.min) then value = data.min end
        end

        -- make sure that the value us below the maximum allowed value
        if(data.max ~= nil) then
          if(value > data.max) then value = data.max end
        end

        text = string.lpad(tostring(value), data.tiles.w, "0")
      end

    end

  end

  if(trigger ~= false)then
    trigger = data.text ~= text
  end

  self:TextEditorImport(data, text)

  if(trigger ~= false and data.onAction ~= nil) then
    data.onAction(self:TextEditorExport(data))
  end

  -- Update the text value
  data.text = self:TextEditorExport(data)
end

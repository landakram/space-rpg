local log = require "lib.log"
local suit = require "lib.suit"

local events = require "states.scenes.events"
local State = require "states.State"

-- TODO: These default layout params could use a clean-up
local layout = {
   width = 400,
   height = love.graphics.getHeight() - 40
}
layout.x = love.graphics.getWidth() / 2 - layout.width / 2
layout.y = love.graphics.getHeight() / 2 - layout.height / 2

local defaultBackgroundColor = { 0/255, 0/255, 0/255, 0.60 }
local defaultBackgroundRect = { "fill", layout.x, layout.y, layout.width, layout.height, 10, 10 }
local defaultLayout = { layout.x + 20, layout.y + 20, 10, 10 }

local Simple = class("Simple")
function Simple:initialize(dialogue, done)
   self.dialogue = dialogue
   self.done = done
   self.suit = suit.new()
end

function Simple:update(dt)
   self.suit.layout:reset(unpack(defaultLayout))

   for _, text in pairs(self.dialogue.texts) do
      self.suit:Label(text, {align = "left"}, self.suit.layout:row(layout.width, 30))
   end

   local button = self.suit:Button("Okay", self.suit.layout:row())
   if button.hit then
      self.done()
   end
end

function Simple:draw()
   love.graphics.setColor(unpack(defaultBackgroundColor))
   love.graphics.rectangle(unpack(defaultBackgroundRect))
   self.suit:draw()
end

local Choice = class("Choice")
function Choice:initialize(dialogue, done)
   self.dialogue = dialogue
   self.done = done
   self.suit = suit.new()
end

function Choice:update(dt)
   self.suit.layout:reset(unpack(defaultLayout))

   for _, text in pairs(self.dialogue.texts) do
      self.suit:Label(text, {align = "left"}, self.suit.layout:row(layout.width, 30))
   end

   self.suit.layout:row()

   for _, choice in pairs(self.dialogue.choices) do
      local button = self.suit:Button(choice.text, self.suit.layout:row())
      if button.hit then
         choice:onSelect()
         self.done()
      end
   end
end

function Choice:draw()
   love.graphics.setColor(unpack(defaultBackgroundColor))
   love.graphics.rectangle(unpack(defaultBackgroundRect))
   self.suit:draw()
end

local Null = class("Null")
function Null:update(dt) end
function Null:draw() end

local DialogueScene = class("DialogueScene", State)
DialogueScene.renderBelow = true

function DialogueScene:initialize(eventManager, dialogue)
   local function done()
      eventManager:fireEvent(events.PopScene())
   end

   ImplementationClass = self:implementationClass(dialogue.type)
   self.implementation = ImplementationClass(dialogue, done)
end

function DialogueScene:implementationClass(type)
   if type == "choice" then
      return Choice
   elseif type == "simple" then
      return Simple
   else
      return Null
   end
end

function DialogueScene:load() end

function DialogueScene:update(dt)
   self.implementation:update(dt)
end

function DialogueScene:draw()
   self.implementation:draw()
end

return DialogueScene

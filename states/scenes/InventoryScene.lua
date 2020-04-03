local log = require "lib.log"
local inspect = require "lib.inspect"
local suit = require "lib.suit"

local fonts = require "fonts"

local events = require "states.scenes.events"
local State = require "states.State"

local layout = {
   width = 400,
   height = love.graphics.getHeight() - 40
}
layout.x = love.graphics.getWidth() / 2 - layout.width / 2
layout.y = love.graphics.getHeight() / 2 - layout.height / 2

local defaultBackgroundColor = { 0/255, 0/255, 0/255, 0.60 }
local defaultBackgroundRect = { "fill", layout.x, layout.y, layout.width, layout.height, 10, 10 }
local defaultLayout = { layout.x + 20, layout.y + 20, 10, 10 }

local InventoryScene = class("InventoryScene", State)
InventoryScene.renderBelow = true

function InventoryScene:initialize(inventory, eventManager)
   self.inventory = inventory
   self.eventManager = eventManager
   self.suit = suit.new()
end

function InventoryScene:load()
   self.eventManager:addListener(
      "KeyPressed", self,
      function(_, event)
         log.debug("KeyPressed", event.key)
         if event.key == "escape" then
            self.eventManager:fireEvent(events.ExitInventory())
         end
      end
   )
end

function InventoryScene:unload()
   log.debug("unload")
   self.eventManager:removeListener("KeyPressed", "InventoryScene")
end

function InventoryScene:update(dt)
   self.suit.layout:reset(unpack(defaultLayout))

   self.suit:Label("Inventory", {align = "left", font = fonts.headerFont}, self.suit.layout:row(200, 30))

   for _, item in pairs(self.inventory.items) do
      -- log.debug(inspect(item))
      self.suit:Label(item.name, {align = "left"}, self.suit.layout:row(200, 10))
   end
end

function InventoryScene:draw()
   love.graphics.setColor(unpack(defaultBackgroundColor))
   love.graphics.rectangle(unpack(defaultBackgroundRect))
   self.suit:draw()
end

return InventoryScene

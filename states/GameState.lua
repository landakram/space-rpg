local State = require "states.State"
local Stack = require "states.Stack"
local ExploreScene = require "states.scenes.ExploreScene"
local StartPointScene = require "states.scenes.definitions.StartPointScene"

local GameState = class("GameState", State)

local Inventory = Component.create(
   "inventory",
   {"items", "size"},
   {
      items = {
         { name = "Candle"},
         { name = "Sand"}
      },
      size = 10
   }
)

function GameState:initialize(eventManager)
   self.eventManager = eventManager
   self.sceneStack = Stack()
end

function GameState:load()
   local sceneDefinition = StartPointScene(self.eventManager)
   self.sceneStack:push(
      ExploreScene(
         sceneDefinition,
         self.eventManager,
         self.sceneStack,
         { Inventory() }
      )
   )
end

function GameState:draw()
   self.sceneStack:draw()
end

function GameState:update(dt)
   self.sceneStack:update(dt)
end

return GameState

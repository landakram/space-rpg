local State = require "states.State"
local Stack = require "states.Stack"
local ExploreScene = require "states.scenes.ExploreScene"
local StartPointScene = require "states.scenes.definitions.StartPointScene"

local GameState = class("GameState", State)

function GameState:load()
   print("GameState:load()")
   self.sceneStack = Stack()
   
   local sceneDefinition = StartPointScene(self.sceneStack)

   self.sceneStack:push(ExploreScene(sceneDefinition))
end

function GameState:draw()
   self.sceneStack:draw()
end

function GameState:update(dt)
   self.sceneStack:update(dt)
end

return GameState

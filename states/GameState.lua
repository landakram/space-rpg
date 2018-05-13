local State = require "states.State"
local Stack = require "states.Stack"
local ExploreScene = require "states.scenes.ExploreScene"

local GameState = class("GameState", State)

function GameState:load()
   print("GameState:load()")
   self.sceneStack = Stack()
   self.sceneStack:push(ExploreScene("maps/map.lua", self.sceneStack))
end

function GameState:draw()
   self.sceneStack:draw()
end

function GameState:update(dt)
   self.sceneStack:update(dt)
end

return GameState

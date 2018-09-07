local ExploreScene = require "states.scenes.ExploreScene"
local HutScene = require "states.scenes.definitions.HutScene"

local StartPointScene = class("StartPointScene", SceneDefinition)

function StartPointScene:npcs()
   return {}
end

function StartPointScene:mapPath()
   return "maps/map.lua"
end

function StartPointScene:triggers()
   return {
      hut_door = {
         action = function()
            self.sceneStack:push(
               ExploreScene(HutScene(self.sceneStack))
            )
         end
      }
   }
end

function StartPointScene:initialize(sceneStack)
   self.sceneStack = sceneStack
end

return StartPointScene

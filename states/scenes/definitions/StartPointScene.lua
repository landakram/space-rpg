local events = require "states.scenes.events"

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
            self.eventManager:fireEvent(events.PushScene(HutScene))
         end
      }
   }
end

function StartPointScene:initialize(eventManager)
   self.eventManager = eventManager
end

return StartPointScene

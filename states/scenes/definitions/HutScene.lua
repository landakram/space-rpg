local events = require "states.scenes.events"
local HutScene = class("HutScene", SceneDefinition)

local Chest = Component.create("chest", {"items"})

function HutScene:npcs()
   return {
      {
         startingPoint = {x = 100, y = 100},
         spritePath = "sprites/princessleia.png"
      }
   }
end

function HutScene:mapPath()
   return "maps/hut.lua"
end

function HutScene:triggers()
   return {
      inside_hut_door = {
         type = "door",
         action = function()
            self.eventManager:fireEvent(events.PopScene())
         end,
         shouldTrigger = function(entity)
            return entity:get("interactive")
         end
      },
      chest = {
         components = { Chest({{ name = "Scraps of Paper" }}) },
         collidable = true,
         shouldTrigger = function(entity)
            if entity:get("interactive") then
               local input = entity:get("input")
               return input and input.states.interact
            else
               return false
            end
         end
      }
   }
end

function HutScene:initialize(eventManager)
   self.eventManager = eventManager
end

return HutScene

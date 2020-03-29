local HutScene = class("HutScene", SceneDefinition)

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
         action = function()
            self.sceneStack:pop()
         end,
         shouldTrigger = function(entity)
            return entity:get("interactive")
         end
      },
      chest = {
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

function HutScene:initialize(sceneStack)
   self.sceneStack = sceneStack
end

return HutScene

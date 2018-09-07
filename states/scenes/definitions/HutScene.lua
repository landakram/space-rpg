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
         end
      }
   }
end

function HutScene:initialize(sceneStack)
   self.sceneStack = sceneStack
end

return HutScene

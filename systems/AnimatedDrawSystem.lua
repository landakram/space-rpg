local lume = require "lib.lume"
local inspect = require "lib.inspect"

local AnimatedDrawSystem = class("AnimatedDrawSystem", System)

function AnimatedDrawSystem:requires()
   return {"position", "animations"}
end

function AnimatedDrawSystem:sortedTargets()
   local targets = {}
   for _, t in pairs(self.targets) do
      lume.push(targets, t)
   end

   table.sort(
      targets,
      function(a, b)
         return a:get("position").y < b:get("position").y
      end
   )

   return targets
end

function AnimatedDrawSystem:draw()
   for key, entity in ipairs(self:sortedTargets()) do
      local position = entity:get("position")
      local animations = entity:get("animations")

      animations.animation:draw(animations.image, position.x, position.y)
   end
end

return AnimatedDrawSystem

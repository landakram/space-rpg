local lume = require "lib.lume"

local AnimatedDrawSystem = class("AnimatedDrawSystem", System)

function AnimatedDrawSystem:requires()
   return {"position", "animations"}
end

function AnimatedDrawSystem:draw()
   -- Sort by y position for drawing
   local targets = lume.sort(
      self.targets,
      function(a, b) return a:get("position").y < b:get("position").y end
   )
   
   for _, entity in pairs(targets) do
      local position = entity:get("position")
      local animations = entity:get("animations")

      animations.animation:draw(animations.image, position.x, position.y)
   end
end

return AnimatedDrawSystem

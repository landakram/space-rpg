local lume = require "lib.lume"
local inspect = require "lib.inspect"

local AnimatedDrawSystem = class("AnimatedDrawSystem", System)

function AnimatedDrawSystem:requires()
   return {"position", "animations"}
end

function AnimatedDrawSystem:draw()
   -- TODO this doesn't work
   -- table.sort(
   --    self.targets,
   --    function(a, b) return a:get("position").y < b:get("position").y end
   -- )
   
   for _, entity in pairs(self.targets) do
      local position = entity:get("position")
      local animations = entity:get("animations")

      animations.animation:draw(animations.image, position.x, position.y)
   end
end

return AnimatedDrawSystem

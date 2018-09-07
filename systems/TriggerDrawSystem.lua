local lume = require "lib.lume"
local inspect = require "lib.inspect"

local TriggerDrawSystem = class("TriggerDrawSystem", System)

function TriggerDrawSystem:requires()
   return {"position", "collision", "trigger"}
end

function TriggerDrawSystem:draw()
   for _, entity in pairs(self.targets) do
      local position = entity:get("position")
      local collision = entity:get("collision")

      love.graphics.rectangle("fill", position.x, position.y, collision.w, collision.h)
   end
end

return TriggerDrawSystem

local lume = require "lib.lume"

local CameraTrackingSystem = class("CameraTrackingSystem", System)

function CameraTrackingSystem:requires()
   return {"interactive", "position"}
end

function CameraTrackingSystem:update(dt)
   local player = lume.first(self.targets)
   local position = player:get("position")
   local interactive = player:get("interactive")
   camera:setPosition(position.x, position.y)
end

return CameraTrackingSystem

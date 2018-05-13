local lume = require "lib.lume"

local CameraTrackingSystem = class("CameraTrackingSystem", System)

function CameraTrackingSystem:initialize(camera)
   System.initialize(self)
   self.camera = camera
end

function CameraTrackingSystem:requires()
   return {"interactive", "position"}
end

function CameraTrackingSystem:update(dt)
   local player = lume.first(self.targets)
   local position = player:get("position")
   local interactive = player:get("interactive")
   self.camera:setPosition(position.x, position.y)
end

return CameraTrackingSystem

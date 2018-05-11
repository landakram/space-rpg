local PositionSystem = class("PositionSystem", System)

function PositionSystem:requires()
   return {"position", "velocity"}
end

function PositionSystem:update(dt)
   for _, entity in pairs(self.targets) do
      local position = entity:get("position")
      local velocity = entity:get("velocity")

      position.x = position.x + velocity.vx * dt
      position.y = position.y + velocity.vy * dt
   end
end

return PositionSystem

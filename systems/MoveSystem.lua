local MoveSystem = class("MoveSystem", System)

function MoveSystem:requires()
   return {"input", "velocity"}
end

function MoveSystem:update(dt)
   for _, entity in pairs(self.targets) do
      local input = entity:get("input")
      local velocity = entity:get("velocity")
      if input.movement == "up" then
         velocity.vx = 0
         velocity.vy = -velocity.speed
      elseif input.movement == "down" then
         velocity.vx = 0
         velocity.vy = velocity.speed
      elseif input.movement == "left" then
         velocity.vx = -velocity.speed
         velocity.vy = 0
      elseif input.movement == "right" then
         velocity.vx = velocity.speed
         velocity.vy = 0
      elseif input.movement == "none" then
         velocity.vx = 0
         velocity.vy = 0
      end
   end
end

return MoveSystem

local InteractSystem = class("InteractSystem", System)

function InteractSystem:requires()
   return {"interactive", "input", "collision", "velocity", "animations", "position"}
end

function InteractSystem:getDirection(entity)
   local animations = entity:get("animations")

   local direction
   if animations.animation == animations.animations.up then
      direction = "up"
   elseif animations.animation == animations.animations.down then
      direction = "down"
   elseif animations.animation == animations.animations.left then
      direction = "left"
   elseif animations.animation == animations.animations.right then
      direction = "right"
   end
   return direction
end

function InteractSystem:getInteractionZone(entity, direction, dt)
   local speed = entity:get("velocity").speed
   local position = entity:get("position")

   local interactionZone = {
      x = position.x,
      y = position.y
   }

   if direction == "up" then
      interactionZone.y = interactionZone.y - speed * dt
   elseif direction == "down" then
      interactionZone.y = interactionZone.y + speed * dt
   elseif direction == "left" then
      interactionZone.x = interactionZone.x - speed * dt
   elseif direction == "right" then
      interactionZone.x = interactionZone.x + speed * dt
   end

   return interactionZone
end

function InteractSystem:update(dt)
   for _, entity in pairs(self.targets) do
      local input = entity:get("input")

      if input.states.interact then
         local direction = self:getDirection(entity)
         local interactionZone = self:getInteractionZone(entity, direction, dt)

         local world = entity:get("collision").world
         local _, _, collisions, len = world:check(entity, interactionZone.x, interactionZone.y)

         for i = 1, len do
            local collision = collisions[i]

            -- TODO: copied from CollisionSystem
            if collision.other.get then
               local trigger = collision.other:get("trigger")
               if trigger and trigger.definition.shouldTrigger(entity) then
                  trigger.status.triggered = true
                  trigger.status.by = entity
               end
            end
         end
      end
   end
end

return InteractSystem

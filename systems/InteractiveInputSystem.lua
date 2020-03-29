local InteractiveInputSystem = class("InteractiveInputSystem", System)

function InteractiveInputSystem:requires()
   return {"interactive", "input", "position", "velocity"}
end

function InteractiveInputSystem:update(dt)
   for _, entity in pairs(self.targets) do
      local input = entity:get("input")

      if love.keyboard.isDown("w") then
         input.movement = "up"
      elseif love.keyboard.isDown("s") then
         input.movement = "down"
      elseif love.keyboard.isDown("a") then
         input.movement = "left"
      elseif love.keyboard.isDown("d") then
         input.movement = "right"
      else
         input.movement = "none"
      end

      if love.keyboard.isDown("space") then
         input.states.interact = true
      else
         input.states.interact = false
      end
   end
end

return InteractiveInputSystem

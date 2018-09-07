local AnimationSystem = class("AnimationSystem", System)

function AnimationSystem:requires()
   return {"velocity", "animations"}
end

function AnimationSystem:update(dt)
   for _, entity in pairs(self.targets) do
      local velocity = entity:get("velocity")
      local animations = entity:get("animations")

      if velocity.vy < 0 then
         animations.animation = animations.animations.up
         animations.animation:resume()
      elseif velocity.vy > 0 then
         animations.animation = animations.animations.down
         animations.animation:resume()
      elseif velocity.vx < 0 then
         animations.animation = animations.animations.left
         animations.animation:resume()
      elseif velocity.vx > 0 then
         animations.animation = animations.animations.right
         animations.animation:resume()
      else
         animations.animation:pause()
      end

      animations.animation:update(dt)
   end
end

return AnimationSystem

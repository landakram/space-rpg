local CollisionSystem = class("CollisionSystem", System)

function CollisionSystem:requires()
   return {"collision", "position"}
end

function CollisionSystem:update(dt)
   for _, entity in pairs(self.targets) do
      local position = entity:get("position")
      local collision = entity:get("collision")
      local world = collision.world

      local x, y, _, _ = world:move(entity, position.x + collision.ox, position.y + collision.oy)
      position.x = x - collision.ox
      position.y = y - collision.oy
   end
end

function CollisionSystem:addEntity(entity, category)
   local position = entity:get("position")
   local collision = entity:get("collision")
   local world = collision.world
   local animation = entity:get("animations").animation
   world:add(entity, position.x + collision.ox, position.y + collision.oy, collision.w, collision.h)

   System.addEntity(self, entity, category)
end

function CollisionSystem:removeEntity(entity, component)
   local position = entity:get("position")
   local world = entity:get("collision").world
   world:remove(entity)
   System.removeEntity(self, entity, component)
end

return CollisionSystem

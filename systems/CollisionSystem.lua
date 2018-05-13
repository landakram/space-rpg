local CollisionSystem = class("CollisionSystem", System)

function CollisionSystem:requires()
   return {colliders = {"collision", "position", "velocity"}, collidable = {"collision", "position"}}
end

function CollisionSystem:update(dt)
   -- Reset triggers
   for _, entity in pairs(self.targets.collidable) do
      local trigger = entity:get("trigger")
      if trigger then
         trigger.triggered = false
      end
   end

   for _, entity in pairs(self.targets.colliders) do
      local position = entity:get("position")
      local collision = entity:get("collision")
      local world = collision.world

      local x, y, collisions, len = world:move(
         entity,
         position.x + collision.ox,
         position.y + collision.oy,
         function(item, other)
            if other.get and other:get("trigger") then
               return "cross"
            else
               return "slide"
            end
         end
      )
      position.x = x - collision.ox
      position.y = y - collision.oy

      for i = 1,len do
         local collision = collisions[i]
         print("collided", collision)
         if collision.other.get then
            local trigger = collision.other:get("trigger")
            if trigger then
               trigger.triggered = true
            end
         end
      end
   end
end

function CollisionSystem:addEntity(entity, category)
   local position = entity:get("position")
   local collision = entity:get("collision")
   local world = collision.world
   if not world:hasItem(entity) then
      world:add(
         entity,
         position.x + collision.ox,
         position.y + collision.oy,
         collision.w,
         collision.h
      )
   end

   System.addEntity(self, entity, category)
end

function CollisionSystem:removeEntity(entity, component)
   local position = entity:get("position")
   local world = entity:get("collision").world
   if world:hasItem(entity) then
      world:remove(entity)
   end
   System.removeEntity(self, entity, component)
end

return CollisionSystem

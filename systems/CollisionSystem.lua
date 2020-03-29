local log = require "lib.log"
local lume = require "lib.lume"
local inspect = require "lib.inspect"
local CollisionSystem = class("CollisionSystem", System)

function CollisionSystem:requires()
   return {colliders = {"collision", "position", "velocity"}, collidable = {"collision", "position"}}
end

function CollisionSystem:update(dt)
   -- Reset triggers
   for _, entity in pairs(self.targets.collidable) do
      local trigger = entity:get("trigger")
      if trigger then
         trigger.status = { triggered = false }
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
            if other.get and
               other:get("trigger") and
               not other:get("trigger").definition.collidable
            then
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
         if collision.other.get then
            -- log.debug("collided with trigger!")
            local trigger = collision.other:get("trigger")
            if trigger and trigger.definition.shouldTrigger(entity) then
               trigger.status.triggered = true
               trigger.status.by = entity
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

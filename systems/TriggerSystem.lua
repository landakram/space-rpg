local log = require "lib.log"
local TriggerSystem = class("TriggerSystem", System)

function TriggerSystem:initialize()
   System.initialize(self)
end

function TriggerSystem:requires()
   return {"trigger"}
end

function TriggerSystem:update(dt)
   -- For debugging
   -- triggerSystem = self
   -- items = world:getItems()
   -- for _, item in pairs(items) do
   --    local x, y, w, h = world:getRect(item)
   --    local triggerId = item.get and item:get("trigger") and item:get("trigger").id or nil
   --    local position = item.get and item:get("position")
   --    print(
   --       item,
   --       triggerId,
   --       "collision x", x,
   --       "position x", position and position.x,
   --       "position y", position and position.y,
   --       "collision y", y,
   --       w, h)
   -- end
   -- print('----')
   --

   for _, entity in pairs(self.targets) do
      local trigger = entity:get("trigger")

      if trigger.status.triggered and not trigger.triggeredLastTick then
         log.debug("triggered", trigger.id)

         if trigger.definition then
            trigger.definition:action()
         end
      end

      trigger.triggeredLastTick = trigger.status.triggered
   end
end

return TriggerSystem

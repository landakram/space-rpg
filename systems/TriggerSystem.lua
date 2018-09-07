local TriggerSystem = class("TriggerSystem", System)

function TriggerSystem:initialize(eventManager, triggers)
   self.eventManager = eventManager
   self.triggers = triggers
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

      if trigger.triggered then
         print("triggered", trigger.id)
      end


      if trigger.triggered and not trigger.triggeredLastTick then
         local id = trigger.id
         local triggerDefinition = self.triggers[id]
         if triggerDefinition then
            triggerDefinition:action()
         end
      end

      trigger.triggeredLastTick = trigger.triggered
   end
end

return TriggerSystem

local TriggerSystem = class("TriggerSystem", System)

-- TODO: temporary params to get it working
function TriggerSystem:initialize(eventManager, sceneStack, scene)
   self.eventManager = eventManager
   self.sceneStack = sceneStack
   self.scene = scene
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
         -- TODO: refactor this and handle these elsewhere,
         -- like in some event system or in the trigger itself
         if id == "hut_door" then
            self.sceneStack:push(self.scene)
         elseif id == "inside_hut_door" then
            self.sceneStack:pop()
         end
      end

      trigger.triggeredLastTick = trigger.triggered
   end
end

return TriggerSystem

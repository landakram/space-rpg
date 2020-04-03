local events = require "states.scenes.events"
local ChestSystem = class("ChestSystem", System)

function ChestSystem:initialize(eventManager)
   System.initialize(self)
   self.eventManager = eventManager
end

function ChestSystem:requires()
   return {"chest", "trigger"}
end

function ChestSystem:update(dt)
   for _, target in pairs(self.targets) do
      if target:get("trigger").status.triggered then
         if #target:get("chest").items ~= 0 then
            self.eventManager:fireEvent(events.OpenChest(target))
         else
            self.eventManager:fireEvent(events.ChestIsEmpty())
         end
      end
   end
end

return ChestSystem

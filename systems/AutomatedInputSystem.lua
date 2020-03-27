local lume = require "lib.lume"

local AutomatedInputSystem = class("AutomatedInputSystem", System)

function AutomatedInputSystem:initialize()
   System.initialize(self)
   self.lastTickTime = os.time()
end

function AutomatedInputSystem:requires()
   return {"ai", "input"}
end

function AutomatedInputSystem:update(dt)
   for _, entity in pairs(self.targets) do
      local ai = entity:get("ai")
      local input = entity:get("input")

      if self.lastTickTime + ai.movement.tickTime < os.time() then
         input.movement = lume.weightedchoice({
               ["up"] = 1,
               ["down"] = 1,
               ["left"] = 1,
               ["right"] = 1,
               ["none"] = 5
         })
      end
   end
   self.lastTickTime = os.time()
end

return AutomatedInputSystem

local lume = require "lib.lume"
local inspect = require "lib.inspect"

local InventorySystem = class("InventorySystem", System)

function InventorySystem:requires()
   return {"inventory", "input"}
end

function InventorySystem:update(dt)
end

function InventorySystem:draw()
end

return InventorySystem

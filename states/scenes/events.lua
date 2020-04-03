
local KeyPressed = class("KeyPressed")
function KeyPressed:initialize(key, isRepeat)
   self.key = key
   self.isRepeat = isRepeat
end

local PushScene = class("PushScene")
function PushScene:initialize(sceneClass)
   self.sceneClass = sceneClass
end

local PopScene = class("PopScene")

local ViewInventory = class("ViewInventory")
local ExitInventory = class("ExitInventory")

local OpenChest = class("OpenChest")
function OpenChest:initialize(chest)
   self.chest = chest
end

local ChestIsEmpty = class("ChestIsEmpty")

return {
   KeyPressed = KeyPressed,
   PushScene = PushScene,
   PopScene = PopScene,
   ViewInventory = ViewInventory,
   ExitInventory = ExitInventory,
   OpenChest = OpenChest,
   ChestIsEmpty = ChestIsEmpty
}

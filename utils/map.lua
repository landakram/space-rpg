function getObjects(map)
   return {
      player = getPlayer(map),
      triggers = getTriggers(map)
   }
end

function getTriggers(map)
   local triggers = {}

   for _, obj in pairs(map.objects) do
      if obj.name == "Trigger" then
         table.insert(triggers, obj)
      end
   end

   return triggers
end

function getPlayer(map)
   for _, obj in pairs(map.objects) do
      if obj.name == "Player" then
         return obj
      end
   end
end

return {
   getObjects = getObjects
}

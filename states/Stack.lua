local log = require "lib.log"
local class = require "lib.lovetoys.lib.middleclass"
local Stack = class("Stack")

function Stack:initialize()
   self.states = {}
   self.backCounter = 0
end

function Stack:current()
   if #self.states == 0 then
      return nil
   elseif #self.states > 0 then
      return self.states[#self.states]
   end
end

function Stack:push(element)
   if self:current() and self:current().onPush then
      self:current():onPush()
   end

   table.insert(self.states, element)
   if self:current().load then
      self:current():load()
   end
end

function Stack:pop()
   if self:current() then 
      local removed = table.remove(self.states, #self.states)
      if removed.unload then
         removed:unload()
      end

      if self:current() and self:current().onPop then
         self:current():onPop()
      end
      return removed
   end
end

function Stack:removeAll()
   while self:current() do
      self:pop()
   end
end

function Stack:switch(scene)
   self:removeAll()
   self:push(scene)
end

function Stack:draw()
   for i = 0, #self.states-1 , 1 do
      if self.states[#self.states-i].renderBelow == false then
         self.backCounter = i
         break
      elseif self.states[#self.states-i].renderBelow == true then
         self.backCounter = i + 1
      end
   end
   for i = self.backCounter, 0 , -1 do
      self.states[#self.states-i]:draw() 
   end 
end

function Stack:update(dt)
   if self:current() then
      self:current():update(dt)
   end
end

return Stack

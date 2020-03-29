local State = require "states.State"

local sti = require "lib.sti"
local anim8 = require "lib.anim8"
local log = require "lib.log"
local lume = require "lib.lume"
local inspect = require "lib.inspect"
local bump = require "lib.bump"
local gamera = require "lib.gamera"
local mapUtils = require "utils.map"

local AutomatedInputSystem = require "systems.AutomatedInputSystem"
local InteractiveInputSystem = require "systems.InteractiveInputSystem"
local InteractSystem = require "systems.InteractSystem"
local MoveSystem = require "systems.MoveSystem"
local AnimationSystem = require "systems.AnimationSystem"
local PositionSystem = require "systems.PositionSystem"
local MoveSystem = require "systems.MoveSystem"
local AnimatedDrawSystem = require "systems.AnimatedDrawSystem"
local CollisionSystem = require "systems.CollisionSystem"
local CameraTrackingSystem = require "systems.CameraTrackingSystem"
local TriggerSystem = require "systems.TriggerSystem"
local TriggerDrawSystem = require "systems.TriggerDrawSystem"

local Position = Component.create("position", {"x", "y"}, {x = 0, y = 0})
local Velocity = Component.create("velocity", {"vx", "vy", "speed"})
local Animations = Component.create("animations", {"image", "animation", "animations"})
local Input = Component.create("input", {"movement", "states"}, {movement = "none", states = {}})
local Interactive = Component.create("interactive", {})
local AI = Component.create("ai", {"movement"}, {movement = {tickTime = 0}})
local Collision = Component.create("collision", {"world", "ox", "oy", "w", "h"})
local Trigger = Component.create("trigger", {"id", "definition", "status"}, { status = { triggered = false } })

local SPEED = 150

function Character(imagePath, startPoint, world)
    local sprite = love.graphics.newImage(imagePath)

    local g = anim8.newGrid(32, 48, sprite:getWidth(), sprite:getHeight())
    local animations = {
        down = anim8.newAnimation(g('1-4', 1), 0.1),
        left = anim8.newAnimation(g('1-4', 2), 0.1),
        right = anim8.newAnimation(g('1-4', 3), 0.1),
        up = anim8.newAnimation(g('1-4', 4), 0.1),
    }

    local player = Entity(nil, "character")
    player:add(Position(startPoint.x, startPoint.y))
    player:add(Velocity(0, 0, SPEED))
    player:add(Animations(sprite, animations.down, animations))
    player:add(Input())
    player:add(Collision(world, 0, 24, 32, 24))

    return player
end

function Player(startPoint, world)
    local player = Character("sprites/jedi.png", startPoint, world)
    player:add(Interactive())
    return player
end

function NPC(startPoint, spritePath, world)
    local player = Character(spritePath, startPoint, world)
    player:add(AI())
    return player
end

function createTrigger(params, world, triggerDefinitions)
   local trigger = Entity(nil, "trigger")
   trigger:add(Position(params.x, params.y))
   trigger:add(Collision(world, 0, 0, params.width, params.height))

   local definition = triggerDefinitions[params.type]
   if not definition then
      log.error(string.format("No trigger definition found for trigger. Trigger ID: %s", params.type))
      definition = {}
   end
   -- Should probably use a class at this point
   defaults = {
      action = function() end,
      shouldTrigger = function(entity) return true end,
      collidable = false
   }
   definition = lume.merge(defaults, definition)

   trigger:add(Trigger(params.type, definition))

   return trigger
end

function createTriggers(triggers, world, triggerDefinitions)
   return lume.map(triggers, function(t) return createTrigger(t, world, triggerDefinitions) end)
end


local ExploreScene = class("ExploreScene", State)

function ExploreScene:initialize(definition)
   self.definition = definition
end

function ExploreScene:load()
   local engine = Engine()

   -- Create map
   self.map = sti(self.definition:mapPath(), {"bump"})
   local world = bump.newWorld()
   self.map:bump_init(world)
   local objects = mapUtils.getObjects(self.map)

   -- Create player
   local startPoint = objects.player
   local player = Player(startPoint, world)
   engine:addEntity(player)

   -- Create trigger entities
   local triggers = createTriggers(objects.triggers, world, self.definition:triggers())
   lume.each(triggers, function(t) engine:addEntity(t) end)
   engine:addSystem(TriggerSystem())

   -- Create camera
   local w, h = self.map.tilewidth * self.map.width, self.map.tileheight * self.map.height
   self.camera = gamera.new(0, 0, w, h)
   self.camera:setScale(1.25)

   -- Create NPCs
   for _, npc in pairs(self.definition:npcs()) do
      engine:addEntity(
         NPC(npc.startingPoint, npc.spritePath, world)
      )
   end

   -- Add systems
   engine:addSystem(CameraTrackingSystem(self.camera))
   engine:addSystem(CollisionSystem())
   engine:addSystem(AutomatedInputSystem())
   engine:addSystem(InteractiveInputSystem())
   engine:addSystem(InteractSystem())
   engine:addSystem(MoveSystem())
   engine:addSystem(AnimationSystem())
   engine:addSystem(PositionSystem())

   local layer = self.map:addCustomLayer("Sprites", 3)
   engine:addSystem(AnimatedDrawSystem(), "draw")

   -- For debugging
   -- engine:addSystem(TriggerDrawSystem())

   self.engine = engine

   function layer:draw()
      engine:draw()
   end
end

function ExploreScene:update(dt)
   -- For debugging
   engine = self.engine
   world = self.world

   self.engine:update(dt)
end

function ExploreScene:draw()
    local map = self.map
    local camera = self.camera

    love.graphics.setColor(255, 255, 255)
    camera:draw(function(l, t, w, h)
            map:draw(-l, -t, camera:getScale(), camera:getScale())
    end)
end

return ExploreScene

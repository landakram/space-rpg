local State = require "states.State"

local sti = require "lib.sti"
local anim8 = require "lib.anim8"
local lume = require "lib.lume"
local inspect = require "lib.inspect"
local bump = require "lib.bump"
local gamera = require "lib.gamera"
local mapUtils = require "utils.map"

local AutomatedInputSystem = require "systems.AutomatedInputSystem"
local InteractiveInputSystem = require "systems.InteractiveInputSystem"
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
local Input = Component.create("input", {"movement"}, {movement = {}})
local Interactive = Component.create("interactive", {})
local AI = Component.create("ai", {"movement"}, {movement = {tickTime = 0}})
local Collision = Component.create("collision", {"world", "ox", "oy", "w", "h"})
local Trigger = Component.create("trigger", {"id", "triggered"}, {triggered = false})

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

function NPC(startPoint, world)
    local player = Character("sprites/princessleia.png", startPoint, world)
    player:add(AI())
    return player
end

function createTrigger(params, world)
   local trigger = Entity(nil, "trigger")
   trigger:add(Position(params.x, params.y))
   trigger:add(Collision(world, 0, 0, params.width, params.height))
   trigger:add(Trigger(params.type))

   return trigger
end

function createTriggers(triggers, world)
   return lume.map(triggers, function(t) return createTrigger(t, world) end)
end


local ExploreScene = class("ExploreScene", State)

function ExploreScene:initialize(mapPath, sceneStack)
   self.mapPath = mapPath
   self.sceneStack = sceneStack
end

function ExploreScene:load()
   local engine = Engine()

   self.map = sti(self.mapPath, {"bump"})
   local world = bump.newWorld()
   self.map:bump_init(world)
   local objects = mapUtils.getObjects(self.map)

   local startPoint = objects.player
   local player = Player(startPoint, world)
   engine:addEntity(player)

   -- Create trigger entities
   local triggers = createTriggers(objects.triggers, world)
   lume.each(triggers, function(t) engine:addEntity(t) end)

   local w, h = self.map.tilewidth * self.map.width, self.map.tileheight * self.map.height
   self.camera = gamera.new(0, 0, w, h)
   self.camera:setScale(1.25)

   self.world = world

   local aiPlayer = NPC({x = 100, y = 100}, world)
   engine:addEntity(aiPlayer)

   engine:addSystem(CameraTrackingSystem(self.camera))
   engine:addSystem(CollisionSystem())
   engine:addSystem(AutomatedInputSystem())
   engine:addSystem(InteractiveInputSystem())
   engine:addSystem(MoveSystem())
   engine:addSystem(AnimationSystem())
   engine:addSystem(PositionSystem())

   engine:addSystem(
      TriggerSystem(
         nil,
         self.sceneStack,
         ExploreScene("maps/hut.lua", self.sceneStack)
      )
   )

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

local sti = require "lib.sti"
local anim8 = require "lib.anim8"
local lovetoys = require "lib.lovetoys.lovetoys"
lovetoys.initialize({debug = true, globals = true})
local lume = require "lib.lume"
local inspect = require "lib.inspect"
local bump = require "lib.bump"
local gamera = require "lib.gamera"

local AutomatedInputSystem = require "systems.AutomatedInputSystem"
local InteractiveInputSystem = require "systems.InteractiveInputSystem"
local MoveSystem = require "systems.MoveSystem"
local AnimationSystem = require "systems.AnimationSystem"
local PositionSystem = require "systems.PositionSystem"
local MoveSystem = require "systems.MoveSystem"
local AnimatedDrawSystem = require "systems.AnimatedDrawSystem"
local CollisionSystem = require "systems.CollisionSystem"
local CameraTrackingSystem = require "systems.CameraTrackingSystem"

local Position = Component.create("position", {"x", "y"}, {x = 0, y = 0})
local Velocity = Component.create("velocity", {"vx", "vy", "speed"})
local Animations = Component.create("animations", {"image", "animation", "animations"})
local Input = Component.create("input", {"movement"}, {movement = {}})
local Interactive = Component.create("interactive", {})
local AI = Component.create("ai", {"movement"}, {movement = {tickTime = 0}})
local Collision = Component.create("collision", {"world", "ox", "oy", "w", "h"})

local SPEED = 100

function loadStartPoint(map)
    local defaultPlayer
    for k, object in pairs(map.objects) do
        if object.name == "Player" then
            defaultPlayer = object
            break
        end
    end
    
    map:removeLayer("Player")

    return defaultPlayer
end

function Character(imagePath, startPoint, world)
    local sprite = love.graphics.newImage(imagePath)

    local g = anim8.newGrid(32, 48, sprite:getWidth(), sprite:getHeight())
    local animations = {
        down = anim8.newAnimation(g('1-4', 1), 0.1),
        left = anim8.newAnimation(g('1-4', 2), 0.1),
        right = anim8.newAnimation(g('1-4', 3), 0.1),
        up = anim8.newAnimation(g('1-4', 4), 0.1),
    }

    local player = Entity()
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

function love.load()
    map = sti("maps/map.lua", {"bump"})
    local world = bump.newWorld()
    map:bump_init(world)

    engine = Engine()

    startPoint = loadStartPoint(map)
    local player = Player(startPoint, world)
    engine:addEntity(player)

    local aiPlayer = NPC({x = 100, y = 100}, world)
    engine:addEntity(aiPlayer)

    engine:addSystem(CameraTrackingSystem())

    engine:addSystem(CollisionSystem())
    engine:addSystem(AutomatedInputSystem())
    engine:addSystem(InteractiveInputSystem())
    engine:addSystem(MoveSystem())
    engine:addSystem(AnimationSystem())
    engine:addSystem(PositionSystem())

    local layer = map:addCustomLayer("Sprites", 3)
    engine:addSystem(AnimatedDrawSystem(), "draw")

    local w, h = map.tilewidth * map.width, map.tileheight * map.height
    camera = gamera.new(0, 0, w, h)
    camera:setScale(1.0)

    function layer:draw()
        engine:draw()
    end
end

function love.update(dt)
    engine:update(dt)
end

function love.draw()
    love.graphics.setColor(255, 255, 255)

    camera:draw(function(l, t, w, h)
            map:draw(-l, -t, camera:getScale(), camera:getScale())
    end)
end

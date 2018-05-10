local sti = require "lib.sti"
local anim8 = require "lib.anim8"
local lovetoys = require "lib.lovetoys.lovetoys"
lovetoys.initialize({
        debug = true,
        globals = true
})
local lume = require "lib.lume"
local inspect = require "lib.inspect"

local player
local SPEED = 100

function createEntityTypes()
    Position = Component.create("position", {"x", "y"}, {x = 0, y = 0})
    Velocity = Component.create("velocity", {"vx", "vy", "speed"})
    Animations = Component.create("animations", {"animation", "animations"})
    Sprite = Component.create("sprite", {"image"})
end

function moveSystem()
    MoveSystem = class("MoveSystem", System)

    function MoveSystem:requires()
        return {"position", "velocity"}
    end

    function MoveSystem:update(dt)
        for _, entity in pairs(self.targets) do
            local position = entity:get("position")
            local velocity = entity:get("velocity")
            position.x = position.x + velocity.vx * dt
            position.y = position.y + velocity.vy * dt
        end
    end
end

function animatedDrawSystem()
    AnimatedDrawSystem = class("AnimatedDrawSystem", System)

    function AnimatedDrawSystem:requires()
        return {"position", "animations", "sprite"}
    end

    function AnimatedDrawSystem:initialize(layer)
        self.layer = layer

        function self.layer.draw()
            for _, entity in pairs(self.targets) do
                local position = entity:get("position")
                local animations = entity:get("animations")
                local sprite = entity:get("sprite")

                animations.animation:draw(sprite.image, position.x, position.y)
            end
        end
        
        System:initialize()
    end
end

function interactiveAnimatedMoveSystem()
    InteractiveAnimatedMoveSystem = class("InteractiveAnimatedMoveSystem", System)

    function InteractiveAnimatedMoveSystem:initialize(moveSystem)
        self.moveSystem = moveSystem
        System:initialize()
    end

    function InteractiveAnimatedMoveSystem:requires()
        return lume.extend({"animations"}, self.moveSystem:requires())
    end

    function InteractiveAnimatedMoveSystem:update(dt)
        for _, entity in pairs(self.targets) do
            local velocity = entity:get("velocity")
            local animations = entity:get("animations")

            if love.keyboard.isDown("w") then
                velocity.vx = 0
                velocity.vy = -velocity.speed
                animations.animation = animations.animations.up
                animations.animation:resume()
            elseif love.keyboard.isDown("s") then
                velocity.vx = 0
                velocity.vy = velocity.speed
                animations.animation = animations.animations.down
                animations.animation:resume()
            elseif love.keyboard.isDown("a") then
                velocity.vx = -velocity.speed
                velocity.vy = 0
                animations.animation = animations.animations.left
                animations.animation:resume()
            elseif love.keyboard.isDown("d") then
                velocity.vx = velocity.speed
                velocity.vy = 0
                animations.animation = animations.animations.right
                animations.animation:resume()
            else
                velocity.vx = 0
                velocity.vy = 0
                animations.animation:pause()
            end

            self.moveSystem:update(dt)
            animations.animation:update(dt)
        end
    end

    -- Unfortunate override as part of composing systems.
    -- Not sure if this is an intended use-case for systems.
    function InteractiveAnimatedMoveSystem:addEntity(entity)
        System:addEntity(entity)
        self.moveSystem:addEntity(entity)
    end
end

function mapSystem()
    MapSystem = class("MapSystem", System)

    function MapSystem:initialize(map)
        self.map = map
    end

    function MapSystem:requires()
        return {}
    end

    function MapSystem:draw()
        map:draw()
    end
end

function createSystemTypes()
    moveSystem()
    animatedDrawSystem()
    interactiveAnimatedMoveSystem()
    mapSystem()
end

function loadStartPoint(map)
    local defaultPlayer
    for k, object in pairs(map.objects) do
        if object.name == "Player" then
            defaultPlayer = object
            break
        end
    end
    
    map:removeLayer("Object Layer 1")

    return defaultPlayer
end

function love.load()
    createEntityTypes()
    createSystemTypes()

    map = sti("map.lua")
    startPoint = loadStartPoint(map)

    local sprite = love.graphics.newImage("jedi.png")

    local g = anim8.newGrid(32, 48, sprite:getWidth(), sprite:getHeight())
    local animations = {
        down = anim8.newAnimation(g('1-4', 1), 0.1),
        left = anim8.newAnimation(g('1-4', 2), 0.1),
        right = anim8.newAnimation(g('1-4', 3), 0.1),
        up = anim8.newAnimation(g('1-4', 4), 0.1),
    }

    local player = Entity()
    player:initialize()
    player:add(Sprite(sprite))
    player:add(Position(startPoint.x, startPoint.y))
    player:add(Velocity(0, 0, SPEED))
    player:add(Animations(animations.down, animations))

    engine = Engine()
    engine:addEntity(player)

    engine:addSystem(InteractiveAnimatedMoveSystem(MoveSystem()))

    map:addCustomLayer("Sprites", 2)
    engine:addSystem(MapSystem(map), "draw")

    local layer = map.layers["Sprites"]
    engine:addSystem(AnimatedDrawSystem(layer))
end

function love.update(dt)
    engine:update(dt)
end

function love.draw()
    love.graphics.setColor(255, 255, 255)
    engine:draw()
end

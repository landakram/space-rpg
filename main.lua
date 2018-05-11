local sti = require "lib.sti"
local anim8 = require "lib.anim8"
local lovetoys = require "lib.lovetoys.lovetoys"
lovetoys.initialize({
        debug = true,
        globals = true
})
local lume = require "lib.lume"
local inspect = require "lib.inspect"
local bump = require "lib.bump"

local SPEED = 100

function createEntityTypes()
    Position = Component.create("position", {"x", "y"}, {x = 0, y = 0})
    Velocity = Component.create("velocity", {"vx", "vy", "speed"})
    Animations = Component.create("animations", {"image", "animation", "animations"})
    Input = Component.create("input", {"movement"}, {movement = {}})
    Interactive = Component.create("interactive", {})
    AI = Component.create("ai", {"movement"}, {movement = {tickTime = 0}})
    Collision = Component.create("collision", {"world", "w", "h"})
end

function automatedInputSystem()
    AutomatedInputSystem = class("AutomatedInputSystem", System)

    function AutomatedInputSystem:initialize()
        System.initialize(self)
        self.lastTickTime = os.time()
    end

    function AutomatedInputSystem:requires()
        return {"ai", "input", "position", "velocity"}
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
                self.lastTickTime = os.time()
            end
        end
    end
end

function interactiveInputSystem()
    InteractiveInputSystem = class("InteractiveInputSystem", System)

    function InteractiveInputSystem:requires()
        return {"interactive", "input", "position", "velocity"}
    end

    function InteractiveInputSystem:update(dt)
        for _, entity in pairs(self.targets) do
            local input = entity:get("input")

            if love.keyboard.isDown("w") then
                input.movement = "up"
            elseif love.keyboard.isDown("s") then
                input.movement = "down"
            elseif love.keyboard.isDown("a") then
                input.movement = "left"
            elseif love.keyboard.isDown("d") then
                input.movement = "right"
            else
                input.movement = "none"
            end
        end
    end
end

function moveSystem()
    MoveSystem = class("MoveSystem", System)

    function MoveSystem:requires()
        return {"input", "velocity"}
    end

    function MoveSystem:update(dt)
        for _, entity in pairs(self.targets) do
            local input = entity:get("input")
            local velocity = entity:get("velocity")
            if input.movement == "up" then
                velocity.vx = 0
                velocity.vy = -velocity.speed
            elseif input.movement == "down" then
                velocity.vx = 0
                velocity.vy = velocity.speed
            elseif input.movement == "left" then
                velocity.vx = -velocity.speed
                velocity.vy = 0
            elseif input.movement == "right" then
                velocity.vx = velocity.speed
                velocity.vy = 0
            elseif input.movement == "none" then
                velocity.vx = 0
                velocity.vy = 0
            end
        end
    end
end

function animationSystem()
    AnimationSystem = class("AnimationSystem", System)

    function AnimationSystem:requires()
        return {"velocity", "animations"}
    end

    function AnimationSystem:update(dt)
        for _, entity in pairs(self.targets) do
            local velocity = entity:get("velocity")
            local animations = entity:get("animations")

            if velocity.vy < 0 then
                animations.animation = animations.animations.up
                animations.animation:resume()
            elseif velocity.vy > 0 then
                animations.animation = animations.animations.down
                animations.animation:resume()
            elseif velocity.vx < 0 then
                animations.animation = animations.animations.left
                animations.animation:resume()
            elseif velocity.vx > 0 then
                animations.animation = animations.animations.right
                animations.animation:resume()
            else
                animations.animation:pause()
            end

            animations.animation:update(dt)
        end
    end
end

function positionSystem()
    PositionSystem = class("PositionSystem", System)

    function PositionSystem:requires()
        return {"position", "velocity"}
    end

    function PositionSystem:update(dt)
        for _, entity in pairs(self.targets) do
            local position = entity:get("position")
            local velocity = entity:get("velocity")

            position.x = position.x + velocity.vx * dt
            position.y = position.y + velocity.vy * dt
        end
    end
end

function collisionSystem()
    CollisionSystem = class("CollisionSystem", System)

    function CollisionSystem:requires()
        return {"collision", "position"}
    end

    function CollisionSystem:update(dt)
        for _, entity in pairs(self.targets) do
            local position = entity:get("position")
            local world = entity:get("collision").world

            local x, y, _, _ = world:move(entity, position.x, position.y)
            position.x = x
            position.y = y
        end
    end

    function CollisionSystem:addEntity(entity, category)
        local position = entity:get("position")
        local collision = entity:get("collision")
        local world = collision.world
        local animation = entity:get("animations").animation
        world:add(entity, position.x, position.y, collision.w, collision.h)

        System.addEntity(self, entity, category)
    end

    function CollisionSystem:removeEntity(entity, component)
        local position = entity:get("position")
        local world = entity:get("collision").world
        world:remove(entity)
        print("bye")
        System.removeEntity(self, entity, component)
    end
end

function animatedDrawSystem()
    AnimatedDrawSystem = class("AnimatedDrawSystem", System)

    function AnimatedDrawSystem:requires()
        return {"position", "animations"}
    end

    function AnimatedDrawSystem:draw()
        for _, entity in pairs(self.targets) do
            local position = entity:get("position")
            local animations = entity:get("animations")

            animations.animation:draw(animations.image, position.x, position.y)
        end
    end
end

function createSystemTypes()
    automatedInputSystem()
    interactiveInputSystem()
    animationSystem()
    positionSystem()
    moveSystem()
    animatedDrawSystem()
    collisionSystem()
end

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

function createCharacter(imagePath, startPoint, world)
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
    player:add(Collision(world, 30, 46))

    return player
end

function createPlayer(startPoint, world)
    local player = createCharacter("sprites/jedi.png", startPoint, world)
    player:add(Interactive())
    return player
end

function createNPC(startPoint, world)
    local player = createCharacter("sprites/princessleia.png", startPoint, world)
    player:add(AI())
    return player
end

function love.load()
    createEntityTypes()
    createSystemTypes()

    map = sti("maps/map.lua", {"bump"})
    local world = bump.newWorld()
    map:bump_init(world)

    engine = Engine()

    startPoint = loadStartPoint(map)
    local player = createPlayer(startPoint, world)
    engine:addEntity(player)

    local aiPlayer = createNPC({x = 100, y = 100}, world)
    engine:addEntity(aiPlayer)

    engine:addSystem(CollisionSystem())
    engine:addSystem(AutomatedInputSystem())
    engine:addSystem(InteractiveInputSystem())
    engine:addSystem(MoveSystem())
    engine:addSystem(AnimationSystem())
    engine:addSystem(PositionSystem())

    local layer = map:addCustomLayer("Sprites", 3)
    engine:addSystem(AnimatedDrawSystem(), "draw")

    function layer:draw()
        engine:draw()
    end
end

function love.update(dt)
    engine:update(dt)
end

function love.draw()
    love.graphics.setColor(255, 255, 255)
    map:draw()
end

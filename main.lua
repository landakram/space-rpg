local sti = require "lib.sti"
local anim8 = require "lib.anim8"
local player

function love.load()
    map = sti("map.lua")

    local defaultPlayer
    for k, object in pairs(map.objects) do
        if object.name == "Player" then
            defaultPlayer = object
            break
        end
    end

    map:removeLayer("Object Layer 1")

    map:addCustomLayer("Sprites", 2)
    local layer = map.layers["Sprites"]

    local sprite = love.graphics.newImage("jedi.png")
    local g = anim8.newGrid(32, 48, sprite:getWidth(), sprite:getHeight())

    local animations = {
        down = anim8.newAnimation(g('1-4', 1), 0.1),
        left = anim8.newAnimation(g('1-4', 2), 0.1),
        right = anim8.newAnimation(g('1-4', 3), 0.1),
        up = anim8.newAnimation(g('1-4', 4), 0.1),
    }

    player = {
        image = sprite,
        x = defaultPlayer.x,
        y = defaultPlayer.y,
        speed = 100,
        animations = animations,
        animation = animations.down
    }

    layer.entities = {
        player = player
    }

    function layer:draw()
        for _, entity in pairs(self.entities) do
            entity.animation:draw(entity.image, entity.x, entity.y)
        end
    end
end

function love.update(dt)
    -- if love.keyboard.isDown("w") and love.keyboard.isDown("d") then
    --     player.y = player.y - player.speed * dt
    --     player.x = player.x + player.speed * dt
    --     player.animation = player.animations.up
    --     player.animation:resume()
    -- elseif love.keyboard.isDown("w") and love.keyboard.isDown("a") then
    --     player.y = player.y - player.speed * dt
    --     player.x = player.x - player.speed * dt
    --     player.animation = player.animations.up
    --     player.animation:resume()
    -- elseif love.keyboard.isDown("s") and love.keyboard.isDown("a") then
    --     player.y = player.y + player.speed * dt
    --     player.x = player.x - player.speed * dt
    --     player.animation = player.animations.down
    --     player.animation:resume()
    -- elseif love.keyboard.isDown("s") and love.keyboard.isDown("d") then
    --     player.y = player.y + player.speed * dt
    --     player.x = player.x + player.speed * dt
    --     player.animation = player.animations.down
    --     player.animation:resume()
    if love.keyboard.isDown("w") then
        player.y = player.y - player.speed * dt
        player.animation = player.animations.up
        player.animation:resume()
    elseif love.keyboard.isDown("s") then
        player.y = player.y + player.speed * dt
        player.animation = player.animations.down
        player.animation:resume()
    elseif love.keyboard.isDown("a") then
        player.x = player.x - player.speed * dt
        player.animation = player.animations.left
        player.animation:resume()
    elseif love.keyboard.isDown("d") then
        player.x = player.x + player.speed * dt
        player.animation = player.animations.right
        player.animation:resume()
    else
        player.animation:pause()
    end

    player.animation:update(dt)

    map:update(dt)
end

function love.draw()
    love.graphics.setColor(255, 255, 255)
    map:draw()
end

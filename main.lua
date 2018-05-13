local lovetoys = require "lib.lovetoys.lovetoys"
local dbg = require "lib.debugger"
lovetoys.initialize({debug = true, globals = true})

Stack = require "states.Stack"
GameState = require "states.GameState"

local stack

function love.load()
    stack = Stack()
    stack:push(GameState())
end

function love.update(dt)
    stack:update(dt)
end

function love.draw()
    stack:draw()
end

function love.keypressed(key, u)
    if key == "space" then
        debug.debug()
    end
end

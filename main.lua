dbg = require "lib.debugger"

local fonts = require "fonts"
love.graphics.setFont(fonts.textFont)

local lovetoys = require "lib.lovetoys.lovetoys"
local lurker = require "lib.lurker"

lovetoys.initialize({debug = true, globals = true})

local events = require "states.scenes.events"

Stack = require "states.Stack"
GameState = require "states.GameState"

local stack
local eventManager

function love.load()
    eventManager = EventManager()
    stack = Stack()
    stack:push(GameState(eventManager))
end

function love.update(dt)
    lurker.update()
    stack:update(dt)
end

function love.draw()
    stack:draw()
end

function love.keypressed(key, isRepeat)
    if key == "f1" then
       dbg()
    end

    eventManager:fireEvent(events.KeyPressed(key, isRepeat))
end

--
-- This is an example how to use lick
-- 

local lick = require "lick"
lick.updateAllFiles = true
lick.clearPackages = true

local divider = require "divider"


-- A couple of shortcuts
local lg = love.graphics
local sin, cos, pi = math.sin, math.cos, math.pi

-- The main love callbacks
local time = time or 0
function love.load()
    time = 0
end

function love.update(dt)
    time = time + dt
end

function love.draw(dt)
    lg.push()
    lg.setBlendMode("alpha")
    lg.translate(lg.getWidth() / 2, lg.getHeight() / 2)
    lg.rotate(1 * pi * cos(time / 10))
    lg.scale(1 + cos(time / 2.5) * 0.2, 1 + sin(time / 5) * 0.2)
    for i = 1, 10 do
        lg.setColor(0.75 + cos(pi / i + time) * 0.25, 0, sin(pi / i * time), 0.91)
        lg.circle("fill",
            400 * sin(i / 3 * pi + time / 10),
            300 * sin(i / 4 * pi + time / 10),
            200 * cos(i / 4 * pi + time / 5), 128)
    end
    lg.pop()
    divider.draw()
    love.graphics.print(time)
end

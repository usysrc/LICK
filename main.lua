-- this file contains an example of how to use the livecoding environment
local lick = require "lick"
lick.reset = true
lick.debug = true
local lg = love.graphics
local sin, cos, pi = math.sin, math.cos, math.pi

local time = 0
function love.update(dt)
    time = time + dt
end

function love.draw(dt)
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
end

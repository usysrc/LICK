lick = require "lick"
lick.reset = true

function love.load()
    circle = {}
    circle.x = 1
end

function love.update(dt)
    circle.x = circle.x + dt*5
end

function love.draw(dt)
    love.graphics.setColor(1,1,0)
    love.graphics.circle("fill", 400+100*math.sin(circle.x), 300, 16,16)
end

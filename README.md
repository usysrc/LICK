# livecooding library for LÖVE

This is a small live coding library for LÖVE. 

It contains a customized [love.run](https://love2d.org/wiki/love.run) which watches for file changes in your source and loads if necessary. Errors get redirected to the command line or on screen.

Needs LÖVE 11.3.

# Optional Parameters
* lick.file = "<INSERT CUSTOM FILE HERE>" -- default is "main.lua"
* lick.debug = true -- displays errors in love window
* lick.reset = true -- calls love.load everytime you save the file, if set to false it will only be called when starting Löve
* lick.clearFlag = false -- overrides the clear() function in love.run

# Example main.lua
```Lua
lick = require "lick"
lick.reset = true -- reload the love.load everytime you save

function love.load()
    circle = {}
    circle.x = 1
end

function love.update(dt)
    circle.x = circle.x + dt*5
end

function love.draw(dt)
    love.graphics.circle("fill", 400+100*math.sin(circle.x), 300, 16,16)
end

# livecoding library for LÖVE

This is a small live coding library for [LÖVE](https://love2d.org). 

It contains a customized [love.run](https://love2d.org/wiki/love.run) which watches for file changes in your source and loads if necessary. Errors get redirected to the command line or on screen.

Tested with LÖVE 11.5.

# Optional Parameters
* lick.files = {"main.lua", "anotherfile.lua"} -- list of files to watch, default is {"main.lua"}
* lick.debug = true -- displays errors in love window
* lick.reset = true -- calls love.load every time you save the file, if set to false it will only be called when starting LÖVE
* lick.clearFlag = false -- overrides the clear() function in love.run
* lick.sleepTime = 0.001 -- sleep time in seconds, default is 0.001 if love.graphics.newCanvas is available, otherwise 1
* lick.showReloadMessage = true -- show message when a file is reloaded
* lick.chunkLoadMessage = "CHUNK LOADED" -- message to show when a chunk is loaded
* lick.updateAllFiles = false -- include all .lua files in the directory and subdirectories in the watchlist for changes
* lick.clearPackages = false -- clear all packages in package.loaded on file change

# Example main.lua
```Lua
lick = require "lick"
lick.reset = true -- reload love.load every time you save

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
```
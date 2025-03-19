# livecoding library for LÖVE

This is a small live coding library for [LÖVE](https://love2d.org).

## Overview

The livecoding library for LÖVE provides a simple and efficient way to live code in the LÖVE framework. It allows developers to see changes in their code in real-time without restarting the application. This is achieved by monitoring file changes and reloading the necessary files automatically.

### Key Features
- **Automatic Reloading**: Watches for changes in your source files and reloads them as needed.
- **Error Handling**: Redirects errors to the command line or displays them on the screen, making debugging easier.
- **Customizable**: Offers several optional parameters to customize the behavior of the live coding environment.
- **Compatibility**: Tested and works seamlessly with LÖVE 11.5.

### How It Works

The library overrides the default [love.run](https://love2d.org/wiki/love.run) function to include file watching capabilities. When a file change is detected, it reloads the file and optionally calls `love.load` to reset the game state. Errors encountered during the reload process are captured and displayed either in the console or on the screen, depending on the configuration.

### Getting Started

To use the livecoding library, simply copy `lick.lua` into your project and require it in your own `main.lua` file and set the desired parameters. The library will handle the rest, ensuring that your changes are reflected in real-time.

# Optional Parameters
* lick.debug = true -- displays errors in love window
* lick.reset = true -- calls love.load every time you save the file, if set to false it will only be called when starting LÖVE
* lick.clearFlag = false -- overrides the clear() function in love.run
* lick.sleepTime = 0.001 -- sleep time in seconds, default is 0.001
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

#Live Coding Kit For Löve

A small live coding library for Löve which also enables interactive debugging. It basically just is a customized [love.run](https://love2d.org/wiki/love.run) which presses all errors to the command line(or in debug mode on screen). And reloads the “main.lua” everytime you save.

note: still in development - everything can change

#Optional Parameters
* lick.file = "<INSERT CUSTOM FILE HERE>" -- default is "main.lua"
* lick.debug = true -- displays errors in love window
* lick.reset = true -- calls love.load everytime you save the file, if set to false it will only be called when starting Löve
* lick.clearFlag = false -- overrides the clear() function in love.run


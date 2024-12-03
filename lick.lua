-- lick.lua
--
-- simple LIVECODING environment for Löve
-- overwrites love.run, pressing all errors to the terminal/console or overlays it
--

local lick = {}
lick.debug = false -- show debug output
lick.reset = false -- reset the game and call love.load on file change
lick.clearFlag = false -- clear the screen on file change
lick.sleepTime = love.graphics.newCanvas and 0.001 or 1 -- sleep time in seconds
lick.showReloadMessage = true -- show message when a file is reloaded
lick.chunkLoadMessage = "CHUNK LOADED"
lick.updateAllFiles = false -- include files in watchlist for changes
lick.clearPackages = false -- clear all packages in package.loaded on file change
lick.defaultFile = "main.lua" -- default file to load

-- local variables
local drawok_old, updateok_old, loadok_old
local last_modified = {}
local debugoutput = nil
local luaFiles = {}

-- Error handler wrapping for pcall
local function handle(err)
    return "ERROR: " .. err
end

-- Function to load all .lua files in the directory and subdirectories
local function loadLuaFiles(dir)
    if not lick.updateAllFiles then
        table.insert(luaFiles, lick.defaultFile)
        return
    end
    dir = dir or ""
    local files = love.filesystem.getDirectoryItems(dir)
    for _, file in ipairs(files) do
        local filePath = dir .. (dir ~= "" and "/" or "") .. file
        local info = love.filesystem.getInfo(filePath)
        if info.type == "file" and file:sub(-4) == ".lua" then
            table.insert(luaFiles, filePath)
        elseif info.type == "directory" then
            loadLuaFiles(filePath)
        end
    end
end

-- Initialization
local function load()
    -- Load all lua files in the directory
    loadLuaFiles()

    -- init the lastmodified table for all lua files
    for _, file in ipairs(luaFiles) do
        local info = love.filesystem.getInfo(file)
        last_modified[file] = info.modtime
    end
end

local function reloadFile(file)
    local success, chunk = pcall(love.filesystem.load, file)
    if not success then
        print(tostring(chunk))
        debugoutput = chunk .. "\n"
        return
    end
    if chunk then
        local ok, err = xpcall(chunk, handle)
        if not ok then
            print(tostring(err))
            if debugoutput then
                debugoutput = (debugoutput .. "ERROR: " .. err .. "\n")
            else
                debugoutput = err .. "\n"
            end
        else
            if lick.showReloadMessage then print(lick.chunkLoadMessage) end
            debugoutput = nil
        end
    end
    
    if lick.reset and love.load then
        local loadok, err = xpcall(love.load, handle)
        if not loadok and not loadok_old then
            print("ERROR: " .. tostring(err))
            if debugoutput then
                debugoutput = (debugoutput .. "ERROR: " .. err .. "\n")
            else
                debugoutput = err .. "\n"
            end
            loadok_old = not loadok
        end
    end
end

-- if a file is modified, reload all files
local function checkFileUpdate()
    local modified = false
    for _, file in ipairs(luaFiles) do
        local info = love.filesystem.getInfo(file)
        if info then
            if info.modtime > last_modified[file] then
                modified = true
            end
        end
    end
    if not modified then return end
    -- remove all files from the require cache
    if lick.clearPackages then
        for k, _ in pairs(package.loaded) do
            package.loaded[k] = nil
        end
    end
    for _, file in ipairs(luaFiles) do
        reloadFile(file)
        local info = love.filesystem.getInfo(file)
        last_modified[file] = info.modtime
    end
end

local function update(dt)
    checkFileUpdate()
    local updateok, err = pcall(love.update, dt)
    if not updateok and not updateok_old then
        print("ERROR: " .. tostring(err))
        if debugoutput then
            debugoutput = (debugoutput .. "ERROR: " .. err .. "\n")
        else
            debugoutput = err .. "\n"
        end
    end
    updateok_old = not updateok
end

local function draw()
    local drawok, err = xpcall(love.draw, handle)
    if not drawok and not drawok_old then
        print(tostring(err))
        if debugoutput then
            debugoutput = (debugoutput .. err .. "\n")
        else
            debugoutput = err .. "\n"
        end
    end

    if lick.debug and debugoutput then
        love.graphics.setColor(1, 1, 1, 0.8)
        love.graphics.printf(debugoutput, (love.graphics.getWidth() / 2) + 50, 0, 400, "right")
    end
    drawok_old = not drawok
end


function love.run()
    if love.load then love.load(love.arg.parseGameArguments(arg), arg) end
    math.randomseed(os.time())
    math.random()
    math.random()
    load()

    -- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end
    
    local dt = 0

    -- Main loop time.
    while true do
        -- Process events.
        if love.event then
            love.event.pump()
            for e, a, b, c, d in love.event.poll() do
                if e == "quit" then
                    if not love.quit or not love.quit() then
                        if love.audio then
                            love.audio.stop()
                        end
                        return
                    end
                end

                love.handlers[e](a, b, c, d)
            end
        end

        -- Update dt, as we'll be passing it to update
        if love.timer then
            love.timer.step()
            dt = love.timer.getDelta()
        end

        -- Call update and draw
        if update then update(dt) end -- will pass 0 if love.timer is disabled
        if love.graphics then
            love.graphics.origin()
            love.graphics.clear(love.graphics.getBackgroundColor())
            if draw then draw() end
        end

        if love.timer then love.timer.sleep(lick.sleepTime) end
        if love.graphics then love.graphics.present() end
    end
end

return lick

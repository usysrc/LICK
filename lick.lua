-- lick.lua
--
-- simple LIVECODING environment for Löve
-- overwrites love.run, pressing all errors to the terminal/console or overlays it
--

local lick = {}
lick.debug = false                     -- show debug output
lick.reset = false                     -- reset the game and call love.load on file change
lick.clearFlag = false                 -- clear the screen on file change
lick.sleepTime = 0.001                 -- sleep time in seconds
lick.showReloadMessage = true          -- show message when a file is reloaded
lick.chunkLoadMessage = "CHUNK LOADED" -- message to show when a chunk is loaded
lick.updateAllFiles = false            -- include files in watchlist for changes
lick.clearPackages = false             -- clear all packages in package.loaded on file change
lick.defaultFile = "main.lua"          -- default file to load
lick.fileExtensions = { ".lua" }       -- file extensions to watch
lick.entryPoint = "main.lua"           -- entry point for the game, if empty, all files are reloaded

-- local variables
local drawok_old, updateok_old, loadok_old
local last_modified = {}
local debug_output = nil
local working_files = {}

-- Error handler wrapping for pcall
local function handle(err)
    return "ERROR: " .. err
end

-- Function to load all files in the directory and subdirectories with the given extensions
local function loadWorkingFiles(dir)
    if not lick.updateAllFiles then
        table.insert(working_files, lick.defaultFile)
        return
    end
    dir = dir or ""
    local files = love.filesystem.getDirectoryItems(dir)
    for _, file in ipairs(files) do
        local filePath = dir .. (dir ~= "" and "/" or "") .. file
        local info = love.filesystem.getInfo(filePath)
        if info.type == "file" then
            for _, ext in ipairs(lick.fileExtensions) do
                if file:sub(- #ext) == ext then
                    table.insert(working_files, filePath)
                end
            end
        elseif info.type == "directory" then
            loadWorkingFiles(filePath)
        end
    end
end

-- Initialization
local function load()
    -- Load all files in the directory
    loadWorkingFiles()

    -- init the lastmodified table for all working files
    for _, file in ipairs(working_files) do
        local info = love.filesystem.getInfo(file)
        last_modified[file] = info.modtime
    end
end

local function reloadFile(file)
    local success, chunk = pcall(love.filesystem.load, file)
    if not success then
        print(tostring(chunk))
        debug_output = chunk .. "\n"
        return
    end
    if chunk then
        local ok, err = xpcall(chunk, handle)
        if not ok then
            print(tostring(err))
            if debug_output then
                debug_output = (debug_output .. "ERROR: " .. err .. "\n")
            else
                debug_output = err .. "\n"
            end
        else
            if lick.showReloadMessage then print(lick.chunkLoadMessage) end
            debug_output = nil
        end
    end

    if lick.reset and love.load then
        local loadok, err = xpcall(love.load, handle)
        if not loadok and not loadok_old then
            print("ERROR: " .. tostring(err))
            if debug_output then
                debug_output = (debug_output .. "ERROR: " .. err .. "\n")
            else
                debug_output = err .. "\n"
            end
            loadok_old = not loadok
        end
    end
end

-- if a file is modified, reload all files
local function checkFileUpdate()
    local modified = false
    for _, file in ipairs(working_files) do
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

    if lick.entryPoint ~= "" then
        reloadFile(lick.entryPoint)
    end
    for _, file in ipairs(working_files) do
        if lick.entryPoint == "" then
            reloadFile(file)
        end
        local info = love.filesystem.getInfo(file)
        last_modified[file] = info.modtime
    end
end

local function update(dt)
    checkFileUpdate()
    if not love.update then return end
    local updateok, err = pcall(love.update, dt)
    if not updateok and not updateok_old then
        print("ERROR: " .. tostring(err))
        if debug_output then
            debug_output = (debug_output .. "ERROR: " .. err .. "\n")
        else
            debug_output = err .. "\n"
        end
    end
    updateok_old = not updateok
end

local function draw()
    local drawok, err = xpcall(love.draw, handle)
    if not drawok and not drawok_old then
        print(tostring(err))
        if debug_output then
            debug_output = (debug_output .. err .. "\n")
        else
            debug_output = err .. "\n"
        end
    end

    if lick.debug and debug_output then
        love.graphics.setColor(1, 1, 1, 0.8)
        love.graphics.printf(debug_output, (love.graphics.getWidth() / 2) + 50, 0, 400, "right")
    end
    drawok_old = not drawok
end


function love.run()
    load()
    if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

    -- Workaround for macOS random number generator issue
    -- On macOS, the random number generator can produce the same sequence of numbers
    -- if not properly seeded. This workaround ensures that the random number generator
    -- is seeded correctly to avoid this issue.
    if jit and jit.os == "OSX" then
        math.randomseed(os.time())
        math.random()
        math.random()
    end

    -- We don't want the first frame's dt to include time taken by love.load.
    if love.timer then love.timer.step() end

    local dt = 0

    return function()
        if love.event then
            love.event.pump()
            for name, a, b, c, d, e, f in love.event.poll() do
                if name == "quit" then
                    if not love.quit or not love.quit() then
                        return a or 0
                    end
                end
                love.handlers[name](a, b, c, d, e, f)
            end
        end

        -- Update dt, as we'll be passing it to update
        if love.timer then
            dt = love.timer.step()
        end

        -- Call update and draw
        if update then update(dt) end -- will pass 0 if love.timer is disabled
        if love.graphics and love.graphics.isActive() then
            love.graphics.origin()
            love.graphics.clear(love.graphics.getBackgroundColor())
            if draw then draw() end
            love.graphics.present()
        end

        if love.timer then love.timer.sleep(lick.sleepTime) end
    end
end

return lick

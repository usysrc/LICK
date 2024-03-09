-- lick.lua
--
-- simple LIVECODING environment for Löve
-- overwrites love.run, pressing all errors to the terminal/console or overlays it

local lick = {}
lick.file = "main.lua"
lick.debug = false
lick.reset = false
lick.clearFlag = false
lick.sleepTime = love.graphics.newCanvas and 0.001 or 1
lick.showReloadMessage = true

local drawok_old, updateok_old, loadok_old
local last_modified = 0
local debugoutput = nil

-- Error handler wrapping for pcall
local function handle(err)
    return "ERROR: " .. err
end

-- Initialization
local function load()
    last_modified = 0
end

local function checkFileUpdate()
    local info = love.filesystem.getInfo(lick.file)
    if not info or last_modified >= info.modtime then
        return
    end
    last_modified = info.modtime
    local success, chunk = pcall(love.filesystem.load, lick.file)
    if not success then
        print(tostring(chunk))
        debugoutput = chunk .. "\n"
    end
    local ok, err = xpcall(chunk, handle)

    if not ok then
        print(tostring(err))
        if debugoutput then
            debugoutput = (debugoutput .. "ERROR: " .. err .. "\n")
        else
            debugoutput = err .. "\n"
        end
    else
        if lick.showReloadMessage then print("CHUNK LOADED\n") end
        debugoutput = nil
    end
    if lick.reset then
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
    math.randomseed(os.time())
    math.random()
    math.random()
    load()

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

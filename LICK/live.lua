-- live.lua
--
-- simple LIVECODING environment with löve, overwrites love.run, suppressing errors to the terminal/console



live = {}
live.file = "main.lua"
live.debug = false
live.reset = false
live.clearFlag = false

-- some simplifiers for faster livecoding
draw = love.graphics.draw
rectangle = love.graphics.rectangle



function handle(err)
	return "ERROR: " .. err
end

function live.setFile(str)
	live.file = str or "live.lua"
end

-- Initialization
function live.load()
	last_modified = 0
end

-- load the livecoding file and execute the contained update function
function live.update(dt)
	if love.filesystem.exists(live.file) and last_modified < love.filesystem.getLastModified(live.file) then
		last_modified = love.filesystem.getLastModified(live.file)
		success, chunk = pcall(love.filesystem.load, live.file)
		if not success then
			print(tostring(chunk))
			live.debugoutput = chunk .. "\n"

		end
		ok,err = xpcall(chunk, handle)
		if not ok then 
			print(tostring(err))
			if live.debugoutput then
				live.debugoutput = (live.debugoutput .."ERROR: ".. err .. "\n" )
			else live.debugoutput =  err .. "\n" end 
		end
		if ok then 
			print("CHUNK LOADED\n")
			live.debugoutput = nil
		end
		if live.reset then
		loadok, err = xpcall(love.load, handle)
		if not loadok and not loadok_old then 
		print("ERROR: "..tostring(err))
		if live.debugoutput then
			live.debugoutput = (live.debugoutput .."ERROR: ".. err .. "\n" ) 
		else live.debugoutput =  err .. "\n" end 
		loadok_old = not loadok
	end


	end
	end
	updateok, err = pcall(love.update,dt)
	if not updateok and not updateok_old then 
		print("ERROR: "..tostring(err))
		if live.debugoutput then
			live.debugoutput = (live.debugoutput .."ERROR: ".. err .. "\n" ) 
		else live.debugoutput =  err .. "\n" end 
	end
	
	updateok_old = not updateok
end

function live.draw()
	drawok, err = xpcall(love.draw, handle)
	if not drawok and not drawok_old then 
		print(tostring(err)) 
		if live.debugoutput then
			live.debugoutput = (live.debugoutput .. err .. "\n" ) 
		else live.debugoutput =  err .. "\n" end 
	end
	if live.debug and live.debugoutput then 
		love.graphics.setColor(255,255,255,120)
		love.graphics.print(live.debugoutput, 0, 0)
	 end
	drawok_old = not drawok
end

function love.run()

    if love.load then love.load(arg) end
    live.load()
    local dt = 0

    -- Main loop time.
    while true do
        if love.timer then
            love.timer.step()
            dt = love.timer.getDelta()
        end
       -- if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled
	live.update(dt)
        if love.graphics then
           if not live.clearFlag then love.graphics.clear() end
           -- if love.draw then love.draw() end
	    live.draw()
        end

        -- Process events.
        if love.event then
            for e,a,b,c in love.event.poll() do
                if e == "q" then
                    if not love.quit or not love.quit() then
                        if love.audio then
                            love.audio.stop()
                        end
                        return
                    end
                end
                love.handlers[e](a,b,c)
            end
        end

        if love.timer then love.timer.sleep(1) end
        if love.graphics then love.graphics.present() end

    end

end


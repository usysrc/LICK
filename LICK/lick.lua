-- lick.lua
--
-- simple LIVECODING environment with löve, overwrites love.run, pressing all errors to the terminal/console



lick = {}
lick.file = "main.lua"
lick.debug = false
lick.reset = false
lick.clearFlag = false
lick.sleepTime = love.graphics.newCanvas and 0.001 or 1

function handle(err)
	return "ERROR: " .. err
end

function lick.setFile(str)
	live.file = str or "lick.lua"
end

-- Initialization
function lick.load()
	last_modified = 0
end

-- load the lickcoding file and execute the contained update function
function lick.update(dt)
	if love.filesystem.exists(lick.file) and last_modified < love.filesystem.getLastModified(lick.file) then
		last_modified = love.filesystem.getLastModified(lick.file)
		success, chunk = pcall(love.filesystem.load, lick.file)
		if not success then
			print(tostring(chunk))
			lick.debugoutput = chunk .. "\n"

		end
		ok,err = xpcall(chunk, handle)
		if not ok then 
			print(tostring(err))
			if lick.debugoutput then
				lick.debugoutput = (lick.debugoutput .."ERROR: ".. err .. "\n" )
			else lick.debugoutput =  err .. "\n" end 
		end
		if ok then 
			print("CHUNK LOADED\n")
			lick.debugoutput = nil
		end
		if lick.reset then
			loadok, err = xpcall(love.load, handle)
			if not loadok and not loadok_old then 
				print("ERROR: "..tostring(err))
				if lick.debugoutput then
					lick.debugoutput = (lick.debugoutput .."ERROR: ".. err .. "\n" ) 
				else 
					lick.debugoutput =  err .. "\n"
				end 
				loadok_old = not loadok
			end
		end
	end
	
	updateok, err = pcall(love.update,dt)
	if not updateok and not updateok_old then 
		print("ERROR: "..tostring(err))
		if lick.debugoutput then
			lick.debugoutput = (lick.debugoutput .."ERROR: ".. err .. "\n" ) 
		else lick.debugoutput =  err .. "\n" end
	end
	
	updateok_old = not updateok
end

function lick.draw()
	drawok, err = xpcall(love.draw, handle)
	if not drawok and not drawok_old then 
		print(tostring(err))
		if lick.debugoutput then
			lick.debugoutput = (lick.debugoutput .. err .. "\n" ) 
		else lick.debugoutput =  err .. "\n" end 
	end
	if lick.debug and lick.debugoutput then 
		love.graphics.setColor(255,255,255,120)
		love.graphics.printf(lick.debugoutput, (1024/2)+50, 0, 400, "right")
	 end
	drawok_old = not drawok
end

function love.run()

    if love.load then love.load(arg) end
    lick.load()
    local dt = 0

    -- Main loop time.
    while true do
        -- Process events.
        if love.event then
            for e,a,b,c,d in love.event.poll() do
                if e == "q" or e == "quit" then
                    if not love.quit or not love.quit() then
                        if love.audio then
                            love.audio.stop()
                        end
                        return
                    end
                end
                love.handlers[e](a,b,c,d)
            end
        end

        if love.timer then
            love.timer.step()
            dt = love.timer.getDelta()
        end
	      lick.update(dt)
        if love.graphics then
           if not lick.clearFlag then love.graphics.clear() end
	         lick.draw()
        end

        if love.timer then love.timer.sleep(lick.sleepTime) end
        if love.graphics then love.graphics.present() end

    end

end


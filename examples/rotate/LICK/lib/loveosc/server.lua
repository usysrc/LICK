--[[
	-- luaosc  Copyright (C) 2009  Jost Tobias Springenberg <k-gee@wrfl.de> --
	
    This file is part of luaosc.

    luaosc is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    luaosc is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.	
--]]

-- This is a luaOSC Fork from Jost Tobias Springenberg, additional code and modifications by Tilmann Hars, Headchant.com, Copyright 2010

require "socket"

osc.server = {}
osc.server.host = "localhost"
osc.server.port = 7771
osc.server.socket = socket.udp() or error('error could not create lua socket object')
osc.server.socket:setsockname(osc.server.host, osc.server.port) 
osc.server.socket:settimeout(0)

-- call this in LÖVE update
function osc.server:update(dt)
	
	local message, from = osc.server.socket:receive(1024)
	-- invoke handler function
	if message ~= nil then
		local success, result = pcall(decode, message)	
		if not success then
			print("Error in decoding: \n" .. result)
		else
				success, result = pcall(handle, from, result)
			if not success then
					print("Error in your handler function: \n" .. result)
			end
		end
	end
	if message == "exit" then
		return
	end
	
end


-- use this to start the server in lua only (not with LÖVE!)
function osc.server:start()
		local length = 1024
		while 1 do
			local message, from = self.socket:receivefrom(1024)
			-- invoke handler function
			if message ~= nil then
				local success, result = base.pcall(osc.decode, message)	
				if not success then
					base.io.stderr:write("Error in decoding: \n" .. result)
				else
					success, result = base.pcall(self.handle, from, result)
					if not success then
						base.io.stderr:write("Error in your handler function: \n" .. result)
					end
				end
			end
			if message == "exit" then
				return
			end
		end
	end



function osc.server:setHandler(hdle)
	handle = hdle
end

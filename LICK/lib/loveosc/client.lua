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

local socket = require "socket"
local base = _G
local string = require("string")
local vstruct = require "LICK/lib/loveosc/vstruct" 
local pack = vstruct.pack
local upack = vstruct.unpack

--------------------------------
-- some constants
--------------------------------

osc.client = {}
osc.client.host = "localhost"
osc.client.ip = nil
osc.client.port = 57110
osc.client.timeout = 0

PROTOCOL = "OSC/1.0"

ADJUSTMENT_FACTOR = 2208988800

IMMEDIATE = string.rep('0', 31) .. '1'


function osc.client:send( data )
	local ip, port = osc.client.ip or assert(socket.dns.toip(osc.client.host)), osc.client.port
	-- create a new UDP object
	local udp = assert(socket.udp())
	udp:settimeout(0)

	--print(encode(data))
	assert(udp:sendto(encode(data), ip, port), "could not send data")
	--assert(udp:sendto(data, ip, port), "could not send data")

	-- retrieve the answer and print results, warning: crashes love
	--print(udp:receive() or "")
end


--------------------------------
-- interface functions: 
--     decode(string) 
-- and encode(table)
--------------------------------

function decode(data) 
	if #data == 0 then
		return nil
	end
	if string.match(data, "^#bundle") then
		return decode_bundle(data)
	else
		return decode_message(data)
	end
end


function encode(data)
	local msg = ""
	local idx = 1
	if data == nil then
		return nil
	end
		
	if data[1] == "#bundle" then
		msg = msg .. encode_string(data[1])
		--print("1 "..msg.."\n")
		msg = msg .. encode_timetag(data[2])
		--print("2 "..msg.."\n")
		idx = 3
		while idx <= #data do
			local submsg = encode(data[idx])
			msg = msg .. encode_int(#submsg) .. submsg 
			--print(idx.." "..submsg.."\n")
			idx = idx + 1
		end
		return msg
	else
		local typestring = ","
		local encodings = ""
		idx = idx + 1
		msg = msg .. encode_string(data[1])
		for t, d in iter_pairwise(data, idx) do
			typestring = typestring .. t
			encodings = encodings .. collect_encoding_for_message(t, d)
		end
		--print("else "..msg..encode_string(typestring) .. encodings.."\n")

		return msg .. encode_string(typestring) .. encodings
	end
end


--------------------------------
-- auxilliary functions
--------------------------------

digits = {}
for i=0,9 do digits[i] = string.char(string.byte('0')+i) end
for i=10,36 do digits[i] = string.char(string.byte('A')+i-10) end

function numberstring(number, bas)
	local s = ""
	repeat
		local remainder = base.math.mod(number,bas)
		s = digits[remainder]..s
		number = (number-remainder)/bas
	until number==0
	return s
end


function next_string(astring)
	-- this is a workaraound because the lua pttern matching is 
	-- not as powerful as pcre and I did not want to include another
	-- dependecy to an external re lib
	local pos = 0
	local num_nzero = 0
	local num_zero = 0
	local result = ""
	if astring == nil then
		-- ensure that string is not empty
		base.error("error: string is empty - probably malformated message")
	end
	-- we match every character with the help of gmatch
	for m in string.gmatch(astring, ".") do
		pos = pos + 1
		-- and then check if it is correctly padded with '\0's
		if m ~= '\0' and num_zero == 0 then
			num_nzero = (num_nzero + 1) % 4
			result = result .. m
		elseif num_zero ~= 0 and (num_zero + num_nzero) % 4 == 0 then
			return result, pos
		elseif m == '\0' then
			num_zero = num_zero + 1
			result = result .. m
		else
			return nil
		end
	end
end	

function iter_pairwise(atable, startvalue)
	local index = startvalue - 2
	return function()
		index = index + 2
		return atable[index], atable[index+1]
	end
end

function collect_encoding_for_message(t, data)
	if t == 'i' then
		return encode_int(data)
	elseif t == 'f' then
		return encode_float(data)
	elseif t == 's' then
		return encode_string(data)
	elseif t == 'b' then
		return encode_blob(data)
	end
end

function collect_decoding_from_message(t, data, message)
	table.insert(message, t)
	if t == 'i' then
		table.insert(message, decode_int(data))
		return string.sub(data, 5)
	elseif t == 'f' then
		table.insert(message, decode_float(data))
		return string.sub(data, 5)
	elseif t == 's' then
		local match, last = next_string(data)
		table.insert(message, match)
		return string.sub(data, last)
	elseif t == 'b' then
		local length = decode_int(data)
		table.insert(message, string.sub(data, 4, length))
		return string.sub(data, 4 + length + 1)
	end
end

function get_addr_from_data(data)
	local addr_raw_string,last = next_string(data)
	local result = ""
	if addr_raw_string == nil then
		-- if we could not find an addr something went wrong
		base.error("error: could not extract address from OSC message")
	end
	-- delete possible trailing zeros
	for t in string.gmatch(addr_raw_string, "[^%z]") do
		result = result .. t
	end
	return result, string.sub(data, last)
end

function get_types_from_data(data)
	local typestring, last = next_string(data)
	local result = {}
	if typestring == nil then
		return {}
	end
	-- split typestring into an iterable table
	for t in string.gmatch(typestring, "[^,%z]") do
		table.insert(result, t)
	end
	return result, string.sub(data, last)
end

--------------------------------
-- decoding functions
--------------------------------

function decode_message(data)
	local types, addr, tmp_data = nil
	local message = {}
	addr, tmp_data = get_addr_from_data(data)
	types, tmp_data = get_types_from_data(tmp_data)
	-- ensure that we at least found something
	if addr == nil or types == nil then
		return nil
	end
	for _,t in base.ipairs(types) do
		tmp_data = collect_decoding_from_message(t, tmp_data, message)
	end
	return message
end


function decode_bundle(data) 
	local match, last = next_string(data)
	local tmp_data = nil
	local msg = {}
	local sec, frac
	-- skip first string data since it will only contian #bundle
	tmp_data = string.sub(data, 9)
	-- check that there is a part of the message left
	if not tmp_data then
		return nil
	end
	table.insert(msg, "#bundle")	
	_, sec, frac = upack("> u4 > u4", {string.sub(tmp_data, 1, 8)})
	-- note this is an awful way of decoding to a bin string and
	-- then decoding the frac again TODO: make this nicer
	frac = numberstring(frac, 2)
	if sec == 0 and frac == IMMEDIATE then
		table.insert(msg, 0)
	else
		table.insert(msg, sec - ADJUSTMENT_FACTOR + decode_frac(frac) )
	end
	tmp_data = string.sub(tmp_data, 9)
	while #tmp_data > 0 do
		local length = decode_int(string.sub(tmp_data,1,4))
		table.insert(msg, decode(string.sub(tmp_data, 5, 4 + length)))
		tmp_data = string.sub(tmp_data, 9 + length)
	end
	return msg
end

function decode_frac(bin)
	local frac = 0
	for i=#bin,1 do
		frac = (frac + string.sub(bin, i-1, i)) / 2
	end
	return frac
end	

function decode_float(bin)
	local pos, res = upack("> f4", {bin})
	return res
end

function decode_int(bin)
	local pos, res = upack("> i4", {bin} )
	return res
end

--------------------------------
-- encoding
--------------------------------

function encode_string(astring) 
	local fillbits = (4 - #astring % 4)
	return astring .. string.rep('\0', fillbits)
end

function encode_int(num)
	return pack("> i4",{ num }) 
end

function encode_blob(blob)
	return encode_int(#blob) .. encode_string(#blob)
end

function encode_timetag(tpoint)
	if tpoint == 0 then
		return IMMEDIATE
	else
		local sec = math.floor(tpoint)
		local frac = tpoint - sec
		
		return pack("> u4 > u4", {sec + ADJUSTMENT_FACTOR , encode_frac(frac)})
		
	end
end



function encode_frac(num) 
	local bin = ""
	local frac = num
	while #bin < 32 do
		bin = bin .. base.math.floor(frac * 2)
		frac = (frac * 2) - base.math.floor(frac * 2)
	end
	return bin
end

function encode_float(num)
	return pack("> f4", {num})
end

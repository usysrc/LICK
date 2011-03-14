-- OBJECT.lua
-- object oriented livecoding library
_internal_object_table = {}

-- hump for classing
local Class = require "LICK/lib/hump/.class"
local hlpr = require "LICK/lib/hlpr"
require "LICK/lib/loveosc"


--[[
	OBJECT
--]]
-- @Object: base class
Object = Class(function(self)
	-- TODO: Object base code
	table.insert(_internal_object_table, self)
end)

function Object:update(dt)
	-- TODO: insert typical update
	-- print("updated")
end

--[[
	SCOBJECT
--]]

-- @SCObject: bass class for supercollider communication
SCObject = Class(function(self)
	Object.construct(self)
end)
SCObject:inherit(Object)


--[[
	SCSYNTH
--]]
-- @SCSynth: supercollider synthesizer class
SCSynth = Class(function(self, nodename, freq)
	SCObject.construct(self)
	self.nodename = nodename or "default"
	self.freq = freq or 440
	self.nodeid = 1000 + math.random(1000)
end)
SCSynth:inherit(SCObject)

-- #set a control, TODO: variable lenght of argument-pairs
function SCSynth:set(control, val)
	local var = {
		"#bundle",
		os.time(),
		{
	            "/n_set",
		    "i",
		    self.nodeid,
		    "s",
		    control,
		    "f",
		    val
		}
	}

	osc.client:send(var)
	--print("OUTGOING OSC MESSAGE")
end

--#sends an OSC message to the supercollider to start the synth
function SCSynth:play()
	local var = {
		"#bundle",
		os.time(),
		{
	            "/s_new",
		    "s",
		    self.nodename,
		    "i",
		    self.nodeid,
		    "i",
		    0,
		    "i",
		    0,
		    "s",
		    "freq",
		    "f",
		    self.freq
		}
	}

	osc.client:send(var)
	--print("OUTGOING OSC MESSAGE")
end

--#frees the node on the supercollider server
function SCSynth:free()
	local var = {
		"#bundle",
		os.time()+0.8,
		{
	            "/n_free",
		    "i",
		    self.nodeid,
		    "i",
		    0
		}
	}

	osc.client:send(var)
	--print("OUTGOING OSC MESSAGE")
end

--[[
	DRAWABLE
--]]
-- @Drawable: base class for all drawable stuff
Drawable = Class(function(self, x, y, color)
	self.color = color or hlpr.color("white",255)
	-- call constructor of Object class
	Object.construct(self)

	self.position = Vector(x,y)
	self.pos = self.position
	self.x = self.position.x
	self.y = self.position.y
end)
Drawable:inherit(Object)

-- #can be called via wrapX(max) or wrapX(min,max)
function Drawable:wrapX(min, max)
	if min and max then
		self:wrap("x", min, max)
	elseif min and not max then 
		self:wrap("x", 0, min)
	end
end

-- #can be called via wrapY(max) or wrapY(min,max)
function Drawable:wrapY(min, max)
	if min and max then
		self:wrap("y", min, max)
	elseif min and not max then 
		self:wrap("y", 0, min)
	end
end

-- #internal wrapper
function Drawable:wrap(str, min, max)
	if str == "x" then
		self.position.x = hlpr.wrap(self.position.x, min, max)
	elseif str == "y" then
		self.position.y = hlpr.wrap(self.position.y, min, max)
	end
end

-- #supercollider style 'set'
function Drawable:set(str, val)

	if str == "x" then 
		self.position.x = val or self.position.x
	elseif str == "y" then
		self.position.y = val or self.position.y
	end
	-- TODO: add lots and lots and lots
end

-- #not yet implemented
function Drawable:draw()
	-- TODO: abstract draw code...
end




--[[
	CIRCLE
--]]
-- @Circle: drawable circle
Circle = Class(function(self, x, y, r, s, color)
	self.r = r or 10
	self.s = s or 16
	self.color = color
	-- call constructor of Drawable
	Drawable.construct(self,x,y,color)
end)
Circle:inherit(Drawable)

-- #draw the circle
function Circle:draw(style)
	if style ~= "fill" and style ~= "line" then
		style = "line"
	end
	love.graphics.setColor(unpack(self.color))
	love.graphics.circle(style, self.position.x, self.position.y, self.r, self.s)
end



----------------------------------------
-- Experimental Objects
----------------------------------------


--[[
	LINE
--]]
-- @Line: draw a line
Line = Class(function(self, x, y, tx, ty, color) -- wats the dealio for polylines?
		self.x = x or 0
		self.y = y or 0
		self.tx = tx or 0
		self.ty = ty or 0
		-- call constructor of Drawable
		Drawable.construct(self, x, y, color)
		
	     end)
Line:inherit(Drawable)
-- TODO: FIX the :set("key", value) ... dunno how it works..!

-- #draw the line
function Line:draw(width, style)
   local width=width or 1
   if style ~= "smooth" and style ~= "rough" then
      style = "smooth"
   end
   love.graphics.setLine(width, style)
   love.graphics.setColor(unpack(self.color))
   love.graphics.line(self.position.x, self.position.y, self.tx, self.ty)
end


--[[
	IMAGE
--]]
-- @Image: Image from file
Image = Class(function(self, file, x, y, color, size, orientation)
		 self.image = love.graphics.newImage(file)
		 -- put positions, size, orientation...
		 self.size = size or 1
		 self.color = color or {255,255,255,255}
		 self.r = 0
		 -- call constructor of Drawable
		 Drawable.construct(self,x,y,color)
	      end)
Image:inherit(Drawable)

-- #draw the image
function Image:draw()
	love.graphics.setColor(unpack(self.color))
	love.graphics.draw(self.image, self.position.x, self.position.y,self.r,self.size,self.size)
end

--[[
	POINT
--]]
-- @Point
Point = Class(function(self, x, y, color, size, style)
		 local color=color or ""
		 local size=size or 1
		 local style=style or "smooth"
		 
		 -- should this be here? or in the constructor?
		 self.size = size
		 self.style = style

		 -- call constructor of Drawable		 
		 Drawable.construct(self,x,y,color)
	      end)
Point:inherit(Drawable)

-- #draw the point
function Point:draw()
	love.graphics.setColor(unpack(self.color))
	love.graphics.setPoint(self.size, self.style)
	love.graphics.point(self.position.x, self.position.y)
end



--[[
	Sequencer
--]]

Sequencer = Class(function(self,bpm, timeSig, phraseLength)
	self.timer = 0
	self.frame = 0
	self.beat = 1
	self.bar = 1
	self.phrase = 1
	self.bpm = bpm or 120

	self.timeSignature = timeSig or 8
	self.phraseLength = phraseLength or 4

	self.newBeat = function() end
	self.newBar = function() end
	self.newPhrase = function() end

	Object.construct(self)
end)
Sequencer:inherit(Object)

function Sequencer:update(dt)
	self.timer = self.timer + dt
	self.frame = self.frame + 1
	local _fps = 30
	local fpm = 30 * _fps
	--print(math.floor(fpm))
	if self.frame%(math.floor(fpm)/self.bpm) == 0 then
		self.beat = self.beat + 1
		self.newBeat()
		if self.beat%self.timeSignature == 0 then
			self.bar = self.bar + 1
			self.newBar()
			if self.bar%self.phraseLength == 0 then
				self.phrase = self.phrase + 1
				self.newPhrase()
			end

		end
		
	end

end

-- EXAMPLE:
-- (put in love.load):
-- 	coco = Circle(300,300)
-- (put in love.update):
-- 	coco:set("x", 30)
-- (put in love.draw): 	
-- 	coco:draw("fill")


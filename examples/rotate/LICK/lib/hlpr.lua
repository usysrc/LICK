-- hlpr libary: it's not about nice coding, ist about fast and easy coding
-- by Rukano and Headchant, 2011


-- global math
pi = math.pi
sin = math.sin
deg = math.deg
rad = math.rad


require "LICK/lib/color"
module(...,package.seeall)

-- syntax shortcuts
checkMode = love.graphics.checkMode
circle = love.graphics.circle
clear = love.graphics.clear
draw = love.graphics.draw
drawq = love.graphics.drawq
getBackgroundColor = love.graphics.getBackgroundColor
getBlendMode = love.graphics.getBlendMode
getCaption =love.graphics.getCaption
getColor = love.graphics.getColor
getColorMode = love.graphics.getColorMode
getFont = love.graphics.getFont
getHeight = love.graphics.getHeight
getLineStipple = love.graphics.getLineStipple
getLineStyle = love.graphics.getLineStyle
getLineWidth = love.graphics.getLineWidth
getMaxPointSize = love.graphics.getMaxPointSize
getModes = love.graphics.getModes
getPointSize = love.graphics.getPointSize
getPointStyle = love.graphics.getPointStyle
getScissor = love.graphics.getScissor
getWidth = love.graphics.getWidth
isCreated = love.graphics.isCreated
line = love.graphics.line
newFont = love.graphics.newFont
newFrameBuffer = love.graphics.newFramebuffer
newImage = love.graphics.newImage
newImageFont = love.graphics.newImageFont
newParticleSystem = love.graphics.newParticleSystem
newQuad = love.graphics.newQuad
newScreenshot = love.graphics.newScreenshot
newSpriteBatch = love.graphics.newSpriteBatch
point = love.graphics.point
polygon = love.graphics.polygon
pop = love.graphics.pop
present = love.graphics.present
print = love.graphics.print
printf = love.graphics.printf
push = love.graphics.push
quad = love.graphics.quad
rectagle = love.graphics.rectangle
reset = love.graphics.reset
rotate = love.graphics.rotate
scale = love.graphics.scale
setBackgroundColor = love.graphics.setBackgroundColor
setBlendMode = love.graphics.setBlendMode
setCaption = love.graphics.setCaption
setColor = love.graphics.setColor
setColorMode = love.graphics.setColorMode
setFont = love.graphics.setFont
setIcon = love.graphics.setIcon
setLine = love.graphics.setLine
setLineStipple = love.graphics.setLineStipple
setLineStyle = love.graphics.setLineStyle
setLineWidth = love.graphics.setLineWidth
setMode = love.graphics.setMode
setPoint = love.graphics.setPoint
setPointSize = love.graphics.setPointSize
setPointStyle = love.graphics.setPointStyle
setRenderTarget = love.graphics.setRenderTarget
setScissor = love.graphics.setScissor
toggleFullscreen = love.graphics.toggleFullscreen
translate = love.graphics.translate
triangle = love.graphics.triangle







function color(r, g,b,a)
	local color={}
	local alpha=a or 255
	local name=r or "azure"
	if type(r) == "string" then
		alpha = g or alpha
		color = x11_color_table[name]
	else
		color[1]=r
		color[2]=g
		color[3]=b
	end
	color[4]=alpha
	return color
end

-- clip withing range 
function clip(n,min,max)
	return math.min(math.max(n, min or -math.huge), max or math.huge) 
end

-- wrap within range, updated version
function wrap(n, min, max)
	local min = min or 0
	return ((n - min) % ((max or 0) - min)) + min
end

-- setColor white
function white()
	love.graphics.setColor(255,255,255,255)
end

-- setColor black
function black()
	love.graphics.setColor(0,0,0,255)
end

-- shorter setColor white
function w()
	white()
end

-- shorter setColor black
function b()
	black()
end

-- fill the screen with translucent black
function clear(alpha)
	love.graphics.setColor(0,0,0,alpha)
	love.graphics.rectangle("fill", 0,0,800,600)
end

-- shorter clear
function cls(alpha)
	clear(alpha)
end

-- one time clear
function cls_once()
	love.graphics.setColor(0,0,0,255)
	love.graphics.rectangle("fill", 0,0,800,600)
end


-- returns random values from -1 to 1, g sets the equidistance
function norm_random()
	return 2 * math.random() - 1
end

-- shorte norm_random
function n_rnd()
	return norm_random()
end

-- drunk, brownnoise/drunk walk: x = x +/- random(width)
function drunk(x, width, g)
	x = x or 0
	width = width or 1
	g = g or 100
	return (x + width*norm_random())
end


-- drnk, shorter version of drunk, start is only used the first time
-- this makes some sense whatsoever...
function drnk(width) 
	local last = 0 
	return function() 
		last = last + width * norm_random() 
		return last
	end 
end

-- scaling functions:

function linlin(n,inMin,inMax,outMin,outMax,clip)
   -- ported and adapted from:
   -- SuperCollider SimpleNumber:linlin

   local n=n or 0 -- to avoid giving back nil
   local clip=clip or "minmax" -- default:clip minmax

   if (inMin == nil) or (inMax == nil) or (outMin == nil) or (outMax == nil) then
      -- just in case you forgot the parameters...
      return n
   end

   if clip == "minmax" then
      if n <= inMin then
	 return minoutMin
      elseif n >= inMax then
	 return outMax
      end
   elseif clip == "min" then
      if n <= inMin then
	 return outMin
      end
   elseif clip == "max" then
      if n >= inMax then
	 return outMax
      end
   end

   -- here is the magic!
   n = (((n-inMin)/(inMax-inMin)) * (outMax-outMin)) + outMin 
   return n
end

function linexp(n,inMin,inMax,outMin,outMax,clip)
   -- ported and adapted from:
   -- SuperCollider SimpleNumber:linexp

   local n=n or 0.00001 -- to avoid giving back nil
   local clip=clip or "minmax" -- default:clip minmax

   if (inMin == nil) or (inMax == nil) or (outMin == nil) or (outMax == nil) then
      -- just in case...
      return n
   end

   if clip == "minmax" then
      if n <= inMin then
	 return outMin
      elseif n >= inMax then
	 return outMax
      end
   elseif clip == "min" then
      if n <= inMin then
	 return outMin
      end
   elseif clip == "max" then
      if n >= inMax then
	 return outMax
      end
   end

   -- here is the magic!
   n = math.pow(outMax/outMin, (n-inMin)/(inMax-inMin)) * outMin
   return n
end

function explin(n,inMin,inMax,outMin,outMax,clip)
   -- ported and adapted from:
   -- SuperCollider SimpleNumber:explin

   local n=n or 0.00001 -- to avoid giving back nil
   local clip=clip or "minmax" -- default:clip minmax

   if (inMin == nil) or (inMax == nil) or (outMin == nil) or (outMax == nil) then
      -- just in case...
      return n
   end

   if clip == "minmax" then
      if n <= inMin then
	 return outMin
      elseif n >= inMax then
	 return outMax
      end
   elseif clip == "min" then
      if n <= inMin then
	 return outMin
      end
   elseif clip == "max" then
      if n >= inMax then
	 return outMax
      end
   end

   -- here is the magic!
   n = (((math.log(n/inMin)) / (math.log(inMax/inMin))) * (outMax-outMin)) + outMin
   return n
end

function expexp(n,inMin,inMax,outMin,outMax,clip)
   -- ported and adapted from:
   -- SuperCollider SimpleNumber:expexp

   local n=n or 0.00001 -- to avoid giving back nil
   local clip=clip or "minmax" -- default:clip minmax

   if (inMin == nil) or (inMax == nil) or (outMin == nil) or (outMax == nil) then
      -- just in case...
      return n
   end

   if clip == "minmax" then
      if n <= inMin then
	 return outMin
      elseif n >= inMax then
	 return outMax
      end
   elseif clip == "min" then
      if n <= inMin then
	 return outMin
      end
   elseif clip == "max" then
      if n >= inMax then
	 return outMax
      end
   end
   -- here is the magic!
   n = math.pow(outMax/outMin, math.log(n/inMin) / math.log(inMax/inMin)) * outMin
   return n
end

-- returns easy sine oscillator
function sin()
	local x = 0
	return function(dt)
		x = x + (dt or 0)
		if x > 2 * pi then x = x - 2*pi end
		return math.sin(x)
	end
end

-- updates all objects in the _object table
function update_objects()
	for i,v in ipairs(_internal_object_table) do
		v:update(dt)
	end
end

-- rotate around center
function rotateCenter(angle)
   local angle=angle or 0
   local w, h = getWidth(), getHeight()
   translate(w/2, h/2)
   rotate(angle)
   translate(-w/2, -h/2)
end

-- return a random table entry
function choose(table)
	return table[math.random(#table)]
end

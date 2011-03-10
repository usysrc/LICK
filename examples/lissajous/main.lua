require "LICK"
require "LICK/lib"
ez = require "LICK/lib/hlpr"
lick.reset = true
lick.clearFlag = true


-- put in main.lua
function love.load()
	
	declare({ 
		t = 0,
		x = 0,
		y = 0,
		o1 = 0,
		o2 = 0,
		g1 = 0,
		g2 = 0,
		k = 0,
		h = 0,
		circle = Circle(200,200,1,32, ez.color("white"))
	})
	
	
end

function love.update(dt)
	circle.color = ez.color("green", 150)
	h = 5 + 0.01
	k = 1 + 0.0001
end

function love.draw()
	ez.cls(20)
	love.graphics.setBlendMode("alpha")

	for i=1,500 do
		t = t + 0.01
		o1 = 1 * h
		o2 = 2.5 * k
		g1 = 400 
		g2 = 300
		scale = 300 
		x = scale * sin(o1 * t) + g1
		y = scale * sin(o2 * t) + g2
		circle.pos.x = x
		circle.pos.y = y


		circle:draw("fill")
	end
	love.graphics.setBlendMode("multiplicative")

	
end


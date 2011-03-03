require "LICK"
require "LICK/lib"
ez = require "LICK/lib/hlpr"
lick.reset = true
lick.clearFlag = true

function love.load()
	circle = Circle(300, 300, 5., 32, ez.color("orange"))
	x = x or 0
	sin1 = ez.sin(1)
end

function love.update(dt)
	circle.pos.x = circle.pos.x + dt *200

	circle:wrapX(200, 300)
	x = x + dt * 3
end

function love.draw()
	ez.cls(10)
	push()
	ez.rotateCenter(x)
	circle:draw("fill")
	pop()
end

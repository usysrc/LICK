local lg = love.graphics

local divider = {}
local width = 16
divider.draw = function()
    lg.setColor(1,1,1)
    lg.rectangle("fill", lg.getWidth()/2-width/2, 0, width, lg.getHeight())
end

return divider
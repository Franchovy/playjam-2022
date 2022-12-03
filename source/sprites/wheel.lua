import "engine"

class("Wheel").extends(gfx.sprite)

function Wheel.new() 
	return Wheel()
end

function Wheel:init()
	Wheel.super.init(self, gfx.image.new("images/wheel"))
	self.type = "Wheel"
	
	local spriteSize = self:getSize()
	local marginSize = 15
	self:setCollideRect(
		marginSize, 
		marginSize, 
		spriteSize - marginSize * 2, 
		spriteSize - marginSize * 2
	)
	self:add()
end

function Wheel:turnLeft() 
	x += 5
end
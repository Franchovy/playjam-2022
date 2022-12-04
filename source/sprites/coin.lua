import "engine"

class('Coin').extends(gfx.sprite)

function Coin.new(image) 
	return Coin(image)
end

function Coin:init(image)
	Coin.super.init(self, image)
	self.type = "Coin"
	print(image)
	
	self:setCollideRect(0, 0, self:getSize())
end

function Coin:destroy()
	self:remove()
end

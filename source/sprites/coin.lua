import "engine"

class('Coin').extends(Sprite)

function Coin.new(image) 
	return Coin(image)
end

function Coin:init(image)
	Coin.super.init(self, image)
	self.type = spriteTypes.coin
	
	self:setCollideRect(0, 0, self:getSize())
end

function Coin:isGrabbed()
	self:setVisible(false)
end

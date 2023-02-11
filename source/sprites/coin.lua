import "engine"

class('Coin').extends(Sprite)

function Coin.new() 
	return Coin()
end

function Coin:init()
	local image = gfx.image.new(images.coin)
	Coin.super.init(self, image:invertedImage())
	self.type = spriteTypes.coin
	
	self.hasBeenGrabbed = false
	
	self:setCollideRect(0, 0, self:getSize())
end

function Coin:isGrabbed()
	self:setVisible(false)
end
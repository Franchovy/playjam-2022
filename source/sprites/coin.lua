import "engine"

class('Coin').extends(Sprite)

function Coin.new() 
	return Coin()
end

function Coin:init()
	Coin.super.init(self)
	
	local image = gfx.image.new(kImages.coin)
	self:setImage(image)
	self.type = spriteTypes.coin
	
	self.hasBeenGrabbed = false
	
	self:setCollideRect(0, 0, self:getSize())
end

function Coin:isGrabbed()
	self:setVisible(false)
end
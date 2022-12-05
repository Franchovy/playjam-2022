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

function Coin:update()
	-- Collision check for players
	
	local overlappingSprites = self:overlappingSprites()
	
	for _, other in pairs(overlappingSprites) do
		if other.type == spriteTypes.player then
			-- Die
			self:isGrabbed()
		end
	end
end

function Coin:isGrabbed()
	self:isVisible(false)
end

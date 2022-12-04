import "engine"

class('Coin').extends(Sprite)

function Coin.new(image) 
	return Coin(image)
end

function Coin:init(image)
	Coin.super.init(self, image)
	self.type = "Coin"
	print(image)
	
	self:setCollideRect(0, 0, self:getSize())
	
	collisionHandler:setCollidesForSprite(self, spriteTypes.player, collisionTypes.overlap)
	
	self:activateCollisionResponse()
end

function Coin:update()
	
	-- Collision check for players
	
	local collisions = collisionHandler:getCollisionsForSprite(self)
	
	for targetType, collisionType in collisions do
		if targetType == spriteTypes.player then
			-- Die
			self:destroy()
		end
	end
end

function Coin:destroy()
	self:remove()
end

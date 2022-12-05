import "engine"

class('KillBlock').extends(Sprite)

function KillBlock.new(image) 
	return KillBlock(image)
end

function KillBlock:init(image)
	KillBlock.super.init(self, image)
	self.type = spriteTypes.killBlock
	
	----------------
	-- Set up Sprite
	
	self:setCollideRect(0, 0, self:getSize())
	self:setCenter(0, 0)
end

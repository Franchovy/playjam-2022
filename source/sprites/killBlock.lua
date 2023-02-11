import "engine"

class('KillBlock').extends(Sprite)

function KillBlock.new() 
	return KillBlock()
end

function KillBlock:init()
	local image = gfx.image.new(images.killBlock)
	KillBlock.super.init(self, image)
	self.type = spriteTypes.killBlock
	
	----------------
	-- Set up Sprite
	
	self:setCollideRect(0, 0, self:getSize())
	self:setCenter(0, 0)
end


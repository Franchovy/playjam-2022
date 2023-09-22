import "engine"

class('KillBlock').extends(Sprite)

function KillBlock.new() 
	return KillBlock()
end

function KillBlock:init()
	--local image = getImage(kImages.killBlock)
	KillBlock.super.init(self)
	self.type = spriteTypes.killBlock
	
	local image = gfx.image.new(kImages.killBlock)
	self:setImage(image)
	
	----------------
	-- Set up Sprite
	
	self:setCollideRect(0, 0, self:getSize())
	self:setCenter(0, 0)
end


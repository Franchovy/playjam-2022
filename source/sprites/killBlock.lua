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


function KillBlock:setSize(width, height)
	KillBlock.super.setSize(self, width, height)
	self:setImage(gfx.image.new(width, height))
	
	self:onSizeChanged()
end

function KillBlock:onSizeChanged()
	self:setCollideRect(0, 0, self:getSize())
	self:drawSelf()
end
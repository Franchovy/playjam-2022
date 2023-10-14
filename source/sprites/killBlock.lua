import "engine"
import "constant/images"
import "constant/spriteTypes"
import "constant/collisionGroups"

class('KillBlock').extends(Sprite)

function KillBlock.new() 
	return KillBlock()
end

function KillBlock:init()
	KillBlock.super.init(self)
	self.type = spriteTypes.killBlock
	
	local image = gfx.image.new(kImages.killBlock)
	self:setImage(image)
	self:setCollideRect(0, 0, self:getSize())
	self:setCenter(0, 0)
end


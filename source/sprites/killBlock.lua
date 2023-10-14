import "engine"
import "constant"
import "playdate"

class('KillBlock').extends(playdate.sprite)

function KillBlock.new() 
	return KillBlock()
end

function KillBlock:init()
	KillBlock.super.init(self)
	self.type = spriteTypes.killBlock
	print(thisIsMyTestVariable)
	local image = gfx.image.new(kImages.killBlock)
	self:setImage(image)
	self:setCollideRect(0, 0, self:getSize())
	self:setCenter(0, 0)
end


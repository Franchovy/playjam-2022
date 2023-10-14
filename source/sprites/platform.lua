import "engine"
import "constant"

class('Platform').extends(playdate.sprite)

function Platform.new(width, height) 
	return Platform(width, height)
end

function Platform:init(width, height)
	Platform.super.init(self, gfx.image.new(width, height))
	self.type = spriteTypes.platform
	local image = gfx.image.new("images/sprites/platform")
	self:setImage(image)
	self:setCollideRect(0, 0, self:getSize())
	self:setCenter(0, 0)
end

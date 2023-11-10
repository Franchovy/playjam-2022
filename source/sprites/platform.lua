import "engine"
import "constant"

class('Platform').extends(playdate.sprite)

function Platform.new() 
	return Platform()
end

function Platform:init()
	Platform.super.init(self, gfx.image.new(kAssetsImages.platform))
	self.type = kSpriteTypes.platform
	
	self:setCollideRect(0, 0, self:getSize())
	self:setCenter(0, 0)
end

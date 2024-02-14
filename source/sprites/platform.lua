import "engine"
import "constant"

local gfx <const> = playdate.graphics

class('Platform').extends(gfx.sprite)

local platformImage

function Platform.new() 
	return Platform()
end

function Platform:init()
	Platform.super.init(self)
	
	if platformImage == nil then
		platformImage = gfx.image.new(kAssetsImages.platform)
	end
	
	self:setImage(platformImage)
	
	self.type = kSpriteTypes.platform
	self:setCenter(0, 0)
	self:setOpaque(true)
	self:setUpdatesEnabled(false)
end

import "engine"
import "constant"

class("LevelEnd").extends(playdate.graphics.sprite)

function LevelEnd.new()
	return LevelEnd()
end

function LevelEnd:init()
	LevelEnd.super.init(self)
	self.type = kSpriteTypes.levelEnd
	
	local image = playdate.graphics.image.new(kAssetsImages.levelEnd)
	self:setImage(image)
	self:setCenter(0, 0)
	self:setCollideRect(self:getBounds())
end
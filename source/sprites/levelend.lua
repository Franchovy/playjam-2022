import "engine"
import "constant"

local gfx <const> = playdate.graphics

class("LevelEnd").extends(gfx.sprite)

function LevelEnd.new()
	return LevelEnd()
end

function LevelEnd:init()
	LevelEnd.super.init(self)
	self.type = kSpriteTypes.levelEnd
	
	local image = gfx.image.new(kAssetsImages.levelEnd)
	self:setImage(image)
	self:setCenter(0, 0)
	self:setCollideRect(self:getBounds())
	
	self:setUpdatesEnabled(false)
	self:setGroupMask(kCollisionGroups.static)
end
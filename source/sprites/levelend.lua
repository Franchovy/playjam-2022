import "engine"
import "constant/images"
import "constant/spriteTypes"
import "constant/collisionGroups"

class("LevelEnd").extends("Sprite")

function LevelEnd.new()
	return LevelEnd()
end

function LevelEnd:init()
	LevelEnd.super.init(self)
	self.type = spriteTypes.levelEnd
	
	local image = gfx.image.new(kImages.levelEnd)
	self:setImage(image)
	self:setCenter(0, 0)
	self:setCollideRect(self:getBounds())
end
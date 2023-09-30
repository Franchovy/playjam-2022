import "engine"

class("LevelEnd").extends("Sprite")

function LevelEnd.new()
	return LevelEnd()
end

function LevelEnd:init()
	LevelEnd.super.init(self)
	
	local image = gfx.image.new(kImages.levelEnd)
	self:setImage(image)
	self:setCenter(0, 0)
	self.type = spriteTypes.levelEnd
	self:setCollideRect(self:getBounds())
end
import "engine"
import "constant"
import "playdate"
import "utils/periodicBlinker"

class('KillBlock').extends(playdate.graphics.sprite)

function KillBlock.new(periodicBlinker) 
	return KillBlock(periodicBlinker)
end

function KillBlock:init(periodicBlinker)
	KillBlock.super.init(self)
	self.type = kSpriteTypes.killBlock
	
	local image = playdate.graphics.image.new(kAssetsImages.killBlock)
	self:setImage(image)
	self:setCollideRect(0, 0, self:getSize())
	self:setCenter(0, 0)
	
	self.periodicBlinker = periodicBlinker
	self:setGroupMask(kCollisionGroups.static)
end

function KillBlock:update()
	KillBlock.super.update(self)
	
	if self.periodicBlinker.hasChanged then
		local image = self:getImage()
		image:setInverted(self.periodicBlinker.blinker.on)
		self:setImage(image)
		self:markDirty()
	end
end
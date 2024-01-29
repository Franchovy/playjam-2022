import "engine"
import "constant"
import "playdate"
import "utils/periodicBlinker"

local gfx <const> = playdate.graphics
local periodicBlinkerKillblock

class('KillBlock').extends(gfx.sprite)

local image
local imageInverted

function KillBlock.new(periodicBlinker) 
	return KillBlock(periodicBlinker)
end

function KillBlock:init(periodicBlinker)
	KillBlock.super.init(self)
	self.type = kSpriteTypes.killBlock
	
	if image == nil then
		image = gfx.image.new(kAssetsImages.killBlock)
	end
	
	if imageInverted == nil then
		imageInverted = gfx.image.new(kAssetsImages.killBlock):invertedImage()
	end
	
	self:setImage(image)
	self:setCollideRect(0, 0, self:getSize())
	self:setCenter(0, 0)
	
	if periodicBlinkerKillblock == nil then
		periodicBlinkerKillblock = periodicBlinker
	end
	
	self:setGroupMask(kCollisionGroups.static)
	
	self.isImageInverted = false
end

function KillBlock:update()
	KillBlock.super.update(self)
	
	if periodicBlinkerKillblock.hasChanged then
		self.isImageInverted = periodicBlinkerKillblock.blinker.on
		
		if self.isImageInverted == true then
			self:setImage(imageInverted)
		elseif self.isImageInverted == false then
			self:setImage(image)
		end
		
		self:markDirty()
	end
end
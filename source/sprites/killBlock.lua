import "engine"
import "constant"
import "playdate"
import "utils/periodicBlinker"
import "engine/colliderSprite"

local gfx <const> = playdate.graphics
local periodicBlinkerKillblock

class('KillBlock').extends(ColliderSprite)

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
	self:setCollider(kColliderType.rect, rectNew(0, 0, self:getSize()))
	self:setCollisionType(kCollisionType.static)
	self:setCenter(0, 0)
	
	periodicBlinkerKillblock = periodicBlinker
	
	self:setGroupMask(kCollisionGroups.static)
	
	self.isImageInverted = false
end

function KillBlock:update()
	gfx.sprite.update(self)
	
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

function KillBlock:ready()
	self:readyToCollide()
end

function KillBlock:collisionWith(other)
	if other.className == "Wheel" then
		other:setIsDead()
	end
end
import "engine"
import "constant"
import "engine/colliderSprite"

local gfx <const> = playdate.graphics

class('Platform').extends(ColliderSprite)

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
	
	self:setCollider(kColliderType.rect, playdate.geometry.rect.new(0, 0, self:getSize()))
	self:setCollisionType(kCollisionType.static)
	self:setCenter(0, 0)
	
	self:setOpaque(true)
	
	self:setUpdatesEnabled(false)
end

function Platform:ready()
	self:readyToCollide()
end

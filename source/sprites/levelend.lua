import "engine"
import "constant"
import "engine/colliderSprite"

local gfx <const> = playdate.graphics

class("LevelEnd").extends(ColliderSprite)

function LevelEnd.new()
	return LevelEnd()
end

function LevelEnd:init()
	LevelEnd.super.init(self)
	self.type = kSpriteTypes.levelEnd
	
	local image = gfx.image.new(kAssetsImages.levelEnd)
	self:setImage(image)
	self:setCenter(0, 0)
	self:setCollider(kColliderType.rect, rectNew(0, 0, self:getSize()))
	self:setCollisionType(kCollisionType.triggerStatic)
	
	self:setUpdatesEnabled(false)
	self:setGroupMask(kCollisionGroups.static)
end

function LevelEnd:ready()
	self:readyToCollide()
end

function LevelEnd:collisionWith(other)
	if other.className == "Wheel" then
		other:levelComplete()
	end
end
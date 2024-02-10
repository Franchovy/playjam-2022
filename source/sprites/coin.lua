import "engine"
import "constant"
import "engine/colliderSprite"

local gfx <const> = playdate.graphics

class('Coin').extends(ColliderSprite)

function Coin.new() 
	return Coin()
end

local coinImage
local coinEmptyImage

function Coin:init()
	Coin.super.init(self)
	self.type = kSpriteTypes.coin
	
	if coinImage == nil then
		coinImage = gfx.image.new(kAssetsImages.coin)
		coinEmptyImage = coinImage:copy()
		coinEmptyImage:clear(gfx.kColorClear)
	end
	self:setImage(coinImage)

	self:setCollider(kColliderType.rect, rectNew(0, 0, self:getSize()))
	self:setCollisionType(kCollisionType.trigger)
	self:readyToCollide()
	self:setCenter(0, 0)
	
	self.config = {
		isPicked = false
	}
	
	self:setUpdatesEnabled(false)
	self:setGroupMask(kCollisionGroups.static)
end

function Coin:loadConfig(config)
	self.config.isPicked = config.isPicked

	if self.config.isPicked then
		self:setCollisionType(kCollisionType.ignore)
	else
		self:setCollisionType(kCollisionType.trigger)
	end
	
	self:updateImage()
end

function Coin:copyConfig(config)
	config.isPicked = self.config.isPicked
end

function Coin:reset()
	self.config.isPicked = false
	self:setCollisionType(kCollisionType.trigger)
	
	self:updateImage()
end

function Coin:isGrabbed()
	self.config.isPicked = true
	self:setCollisionType(kCollisionType.ignore)
	self:updateImage()
end

function Coin:updateImage()
	if self.config.isPicked == true then
		self:setImage(coinEmptyImage)
	elseif self.config.isPicked == false then
		self:setImage(coinImage)
	end
	
	self:markDirty()
end

function Coin:collisionWith(other)
	if other.className == "Wheel" then
		self:isGrabbed()
	end
end

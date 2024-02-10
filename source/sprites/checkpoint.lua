import "engine"
import "constant"
import "utils/images"
import "playdate"
import "engine/colliderSprite"

local gfx <const> = playdate.graphics

class("Checkpoint").extends(ColliderSprite)

local kStateKeys = { isSet = "isSet" }

function Checkpoint.new()
	return Checkpoint()
end

function Checkpoint:init()
	Checkpoint.super.init(self)
	
	-- Legacy, to abstract away
	
	self.type = kSpriteTypes.checkpoint
	self:setCenter(0, 0)
	
	self.config = {
		isSet = false
	}
	
	-- Set Image
	
	self:updateImage()
	self:setCollider(kColliderType.rect, rectNew(0, 0, self:getSize()))
	self:setCollisionType(kCollisionType.trigger)
	self:readyToCollide()
	
	-- Sound effects
	
	sampleplayer:addSample("set", kAssetsSounds.checkpointSet)
	
	self:setUpdatesEnabled(false)
end

function Checkpoint:ready()
end

function Checkpoint:isSet()
	return self.config.isSet
end

function Checkpoint:set()
	sampleplayer:playSample("set")
	
	self.config.isSet = true
	
	self:updateImage()
end

function Checkpoint:loadConfig(config)
	self.config.isSet = config.isSet
	
	self:updateImage()
end

function Checkpoint:copyConfig(config)
	config.isSet = self.config.isSet
end

function Checkpoint:reset()
	self.config {
		isSet = false
	}
	
	self:updateImage()
end

function Checkpoint:updateImage()
	local imagePath
	
	if self.config.isSet == true then
		imagePath = kAssetsImages.checkpointSet
	else
		imagePath = kAssetsImages.checkpoint
	end
	
	self:setImage(gfx.image.new(imagePath))
end

function Checkpoint:collisionWith(other)
	if other.className == "Wheel" then
		if not self:isSet() then
			self:set()
			other:hitCheckpoint(self)
		end
	end
end
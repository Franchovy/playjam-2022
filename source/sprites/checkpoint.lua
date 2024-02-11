import "engine"
import "constant"
import "utils/images"
import "playdate"
import "engine/colliderSprite"

local gfx <const> = playdate.graphics
local timer <const> = playdate.timer

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
	self:setCollisionType(kCollisionType.triggerStatic)
	
	-- Sound effects
	
	sampleplayer:addSample("load", kAssetsSounds.checkpointLoad)
	sampleplayer:addSample("set", kAssetsSounds.checkpointSet)
	
	self:setUpdatesEnabled(false)
	
	-- Loading update
	
	self._loadTimer = nil
	self._loadFinished = false
	self._loadPlayer = nil
end

function Checkpoint:ready()
	self:readyToCollide()
end

function Checkpoint:isSet()
	return self.config.isSet
end

function Checkpoint:loadCheckpoint()
	if self._loadTimer == nil then
		self._loadTimer = timer.new(800, function()
			self._loadFinished = true
		end)
		
		self._loadPlayer = sampleplayer:playSample("load")
	end
end

function Checkpoint:stopLoading()
	if self._loadTimer ~= nil then
		self._loadTimer:remove()
		self._loadTimer = nil
	end
	
	if self._loadPlayer ~= nil then
		self._loadPlayer:stop()
		self._loadPlayer = nil
	end
end

function Checkpoint:loadFinished()
	return self._loadFinished
end

function Checkpoint:set()
	print("Set")
	
	if self._loadTimer ~= nil then
		-- Reset (for recycling purposes)
		self._loadTimer:remove()
		self._loadTimer = nil
		self._loadFinished = false
		self._loadPlayer = nil
	end
	
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
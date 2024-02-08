import "engine"
import "constant"
import "utils/images"
import "playdate"

local gfx <const> = playdate.graphics
local timer <const> = playdate.timer

class("Checkpoint").extends(gfx.sprite)

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
	self:setCollideRect(0, -240, 24, 480)
	self:setGroupMask(kCollisionGroups.static)
	
	-- Sound effects
	
	sampleplayer:addSample("set", kAssetsSounds.checkpointSet)
	
	self:setUpdatesEnabled(false)
	
	-- Loading update
	
	self._loadTimer = nil
	self._loadFinished = false
end

function Checkpoint:isSet()
	return self.config.isSet
end

function Checkpoint:loadCheckpoint()
	print("Loading")
	if self._loadTimer == nil then
		self._loadTimer = timer.new(800, function()
			self._loadFinished = true
		end)
	end
end

function Checkpoint:stopLoading()
	print("Stop loading")
	
	if self._loadTimer ~= nil then
		self._loadTimer:remove()
		self._loadTimer = nil
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

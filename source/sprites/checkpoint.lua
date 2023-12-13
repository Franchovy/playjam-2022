import "engine"
import "constant"
import "utils/images"
import "playdate"

class("Checkpoint").extends(playdate.graphics.sprite)

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

function Checkpoint:writeConfig(config)
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
	
	self:setImage(playdate.graphics.image.new(imagePath))
end

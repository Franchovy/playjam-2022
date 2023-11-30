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
	
	-- Sound effects
	
	sampleplayer:addSample("set", kAssetsSounds.checkpointSet)
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
	self.config = table.shallowcopy(config)
	
	self:updateImage()
end

function Checkpoint:getConfig()
	return table.shallowcopy(self.config)
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

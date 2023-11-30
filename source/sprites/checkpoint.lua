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
	
	-- State
	
	self:reset()
	
	-- Set Image
	
	self:updateImage()
	self:setCollideRect(0, -240, 24, 480)
	
	-- Sound effects
	
	sampleplayer:addSample("set", kAssetsSounds.checkpointSet)
end

function Checkpoint:isSet()
	return self:getStateValue(kStateKeys.isSet)
end

function Checkpoint:set()
	sampleplayer:playSample("set")
	
	self:setStateValue(kStateKeys.isSet, true)
	self:updateImage()
end

function Checkpoint:loadConfig(config)
	self:setStateValue(kStateKeys.isSet, config.isSet)
	self:updateImage()
end

function Checkpoint:updateConfig(config)
	config.isSet = self:getStateValue(kStateKeys.isSet)
end

function Checkpoint:reset()
	local state = {}
	state[kStateKeys.isSet] = false
	self:setInitialState(state)
	
	self:updateImage()
end


-- These Methods can be moved into "sprite" once state management is well thought-out.

function Checkpoint:setInitialState(state)
	self._stateInitial = state
	self._state = {}
	
	for k, v in pairs(state) do
		self._state[k] = v
	end
end

function Checkpoint:setStateValue(key, value)
	self._state[key] = value
end

function Checkpoint:getStateValue(key)
	return self._state[key]
end

function Checkpoint:updateImage()
	local imagePath = getImageForState(kAssetsImages.checkpoint, self._state)
	local image = playdate.graphics.image.new(imagePath)
	self:setImage(image)
end

--

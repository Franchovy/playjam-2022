import "engine"
import "constant/images"

class("Checkpoint").extends(Sprite)

local kStateKeys = { isSet = "isSet" }

function Checkpoint.new()
	return Checkpoint()
end

function Checkpoint:init()
	Checkpoint.super.init(self)
	
	-- Legacy, to abstract away
	
	self.type = spriteTypes.checkpoint
	self:setCenter(0, 0)
	
	-- State
	
	local state = {}
	state[kStateKeys.isSet] = false
	self:setInitialState(state)
	
	-- Set Image
	
	self:setImageState()
	self:setCollideRect(self:getBounds())
	
	-- Sound effects
	
	sampleplayer:addSample("set", "sfx/checkpoint_set")
end

function Checkpoint:isSet()
	return self:getStateValue(kStateKeys.isSet)
end

function Checkpoint:set()
	sampleplayer:playSample("set")
	
	self:setStateValue(kStateKeys.isSet, true)
	self:setImageState()
end

-- These Methods can be moved into "Sprite" once state management is well thought-out.

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

function Checkpoint:setImageState()
	local imagePath = getImageForState(kImages.checkpoint, self._state)
	local image = gfx.image.new(imagePath)
	self:setImage(image)
end

--

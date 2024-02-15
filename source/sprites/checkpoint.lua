import "engine"
import "constant"
import "utils/images"
import "playdate"

local gfx <const> = playdate.graphics
local timer <const> = playdate.timer
local _floor <const> = math.floor

class("Checkpoint").extends(gfx.sprite)

local checkPointLoadDuration <const> = 800
local imageCheckpoint, imagetableCheckpointLoad, imagetableCheckpointSet
local loadAnimator, animationLoop, loadAnimationFrameCount

local kStates <const> = { default = 1, load = 2, set = 3 }

function Checkpoint.new()
	return Checkpoint()
end

function Checkpoint:init()
	Checkpoint.super.init(self)
	
	if imageCheckpoint == nil then
		imageCheckpoint = gfx.image.new(kAssetsImages.checkpoint)
	end
	
	if imagetableCheckpointLoad == nil then
		imagetableCheckpointLoad = gfx.imagetable.new(kAssetsImages.checkpointLoad)
		loadAnimationFrameCount = #imagetableCheckpointLoad
	end
	
	if imagetableCheckpointSet == nil then
		imagetableCheckpointSet = gfx.imagetable.new(kAssetsImages.checkpointSet)
	end
	
	if animationLoop == nil then
		animationLoop = gfx.animation.loop.new(nil, imagetableCheckpointSet, true)
		animationLoop.paused = true
	end
	
	-- Legacy, to abstract away
	
	self.type = kSpriteTypes.checkpoint
	self:setCenter(0, 0)
	
	self.config = {
		isSet = false
	}
	
	-- Set Image
	
	self:setSize(24, 48)
	self:setCollideRect(0, -240, 24, 480)
	self:setGroupMask(kCollisionGroups.static)
	
	local _currentLoadAnimationFrame = 1
	local state = kStates.default
	function self:draw(x, y, width, height)
		if state == kStates.default then
			imageCheckpoint:draw(0, 0)
		elseif state == kStates.load then
			imagetableCheckpointLoad:drawImage(_currentLoadAnimationFrame, 0, 0)
		elseif state == kStates.set then
			animationLoop:draw(0, 0)
		end
	end
	
	function self:setState(newState)
		state = newState
	end
	
	function self.setLoadAnimationFrame(frame)
		_currentLoadAnimationFrame = frame
	end
	
	-- Sound effects
	
	sampleplayer:addSample("load", kAssetsSounds.checkpointLoad)
	sampleplayer:addSample("set", kAssetsSounds.checkpointSet)
	
	self:setUpdatesEnabled(false)
	self:setAlwaysRedraw(true)
	
	-- Loading update
	
	self._loadTimer = nil
	self._loadFinished = false
	self._loadPlayer = nil
end

function Checkpoint:isSet()
	return self.config.isSet
end

function Checkpoint:loadCheckpoint()
	if self._loadTimer == nil then
		self._loadTimer = timer.new(checkPointLoadDuration, function()
			self._loadFinished = true
		end)
		
		self._loadTimer.updateCallback = function()
			local currentTime = self._loadTimer.currentTime
			local frame = _floor(currentTime / checkPointLoadDuration * (loadAnimationFrameCount - 1)) + 1
			self.setLoadAnimationFrame(frame)
		end
		
		self._loadPlayer = sampleplayer:playSample("load")
		self:setState(kStates.load)
	end
end

function Checkpoint:stopLoading()
	if self._loadTimer ~= nil then
		self._loadTimer:remove()
		self._loadTimer = nil
		self:setState(kStates.default)
		self.setLoadAnimationFrame(1)
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
	animationLoop.paused = false
	self:setState(kStates.set)
	self.setLoadAnimationFrame(1)
	
	self.config.isSet = true
end

function Checkpoint:loadConfig(config)
	self.config.isSet = config.isSet
	animationLoop.paused = not config.isSet
	self:setState(config.isSet == true and kStates.set or kStates.default)
end

function Checkpoint:copyConfig(config)
	config.isSet = self.config.isSet
end

function Checkpoint:reset()
	self.config {
		isSet = false
	}
end

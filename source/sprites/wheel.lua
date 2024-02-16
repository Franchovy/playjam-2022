import "engine"
import "constant"
import "utils/images"
import "playdate"

local gfx <const> = playdate.graphics

class("Wheel").extends(gfx.sprite)

local maxFallSpeed <const> = 14
local gravity <const> = 1.4
local crankTicksPerCircle <const> = 72

local jumpSpeed <const> = 18
local smallJumpSpeed <const> = 4.5

local smallJumpMaxTicks <const> = 10
local jumpMaxTicks <const> = 14

local crankTickMultiplier <const> = 3
local accelerationManual <const> = 1.0
local maxSpeedManual <const> = 8.0

local speedUpAcceleration <const> = 0.01
local speedUpDragAcceleration <const> = 0.1
local speedUpBrakeAcceleration <const> = 1.5

local velocityDragStep <const> = 0.1
local velocityBrakeStep <const> = 0.2
local maxVelocityX <const> = 11

local isDPadControlsEnabled = nil
local dPadSensitivity <const> = 5

function Wheel.new() 
	return Wheel()
end

function Wheel:init()
	Wheel.super.init(self)
	
	self.imagetable = gfx.imagetable.new(kAssetsImages.wheel)
	
	self:setSize(48, 48)
	self:setImage(self.imagetable[1])
	self:setCenter(0, 0)
	
	self.type = kSpriteTypes.player
	
	self:setCollideRect(self:getBounds())
	self:setGroupMask(kCollisionGroups.player)
	self:setCollidesWithGroupsMask(kCollisionGroups.static)
	
	self.collisionResponse = function(self, other)
		if other.type == kSpriteTypes.platform then
			return kCollisionResponse.slide
		end
		
		return kCollisionResponse.overlap
	end
	
	self.signals = {}
	
	-- Samples
	
	-- Load sound assets
	
	sampleplayer:addSample("coin", kAssetsSounds.coin, 0.5)
	sampleplayer:addSample("bump", kAssetsSounds.bump, 0.3)
	sampleplayer:addSample("land", kAssetsSounds.land, 0.2)
	sampleplayer:addSample("jump", kAssetsSounds.jump, 0.2)
	sampleplayer:addSample("death"..1, kAssetsSounds.death1, 0.6)
	sampleplayer:addSample("death"..2, kAssetsSounds.death2, 0.6)
	sampleplayer:addSample("death"..3, kAssetsSounds.death3, 0.6)
	sampleplayer:addSample(kAssetsSounds.tick, kAssetsSounds.tick, 0.2)
	sampleplayer:addSample(kAssetsSounds.rev, kAssetsSounds.rev, 1)
	
	-- Synth
	
	local sampleSynth = sampleplayer:getSample(kAssetsSounds.rev)
	local synthConfig = {
		sample = sampleSynth,
		attack = 0.5,
		decay = 1.2,
		volume = 0.10,
		frequency = 440
	}
	
	synth:create(kAssetsSounds.rev, synthConfig)		
	
	-- Create Properties
	
	self:resetValues()
	
	isDPadControlsEnabled = Settings:getValue(kSettingsKeys.controlType) == "D-PAD"
end

function Wheel:resetValues() 
	self.isJumping = false
	self.hasJumpedFinished = nil
	self.jumpTimeInTicks = nil
	self.velocityX = 0
	self.velocityY = 0
	self.angle = 0
	self.hasJustDied = false
	self.isAwaitingInput = false
	self.ignoresPlayerInput = true
	self.hasReachedLevelEnd = false
	self.hasTouchedNewCheckpoint = false
	self.hasJustTouchedGround = false
	self._recentCheckpoint = nil
	self._recentLoadingCheckpoint = nil
	self._isLoadingCheckpoint = false
	self._coinCountUpdate = 0
	self.isFrozen = false
	self.normal = {
		x = 0,
		y = 0
	}
	self.normalPrevious = table.shallowcopy(self.normal)
end

function Wheel:getCoinCountUpdate()
	return self._coinCountUpdate
end

function Wheel:setIsDead() 
	if self.hasJustDied then
		return
	end
	
	local random = math.random(3)
	sampleplayer:playSample("death"..random)
	
	-- Freeze all wheel behaviour, no movement or accepted input
	self.ignoresPlayerInput = true
	self.hasJustDied = true
	self.isFrozen = true
	
	if self.signals.onDeath ~= nil then
		self.signals.onDeath()
	end
end

function Wheel:getRecentCheckpoint()
	self.hasTouchedNewCheckpoint = false
	return self._recentCheckpoint
end

function Wheel:startGame()
	self.ignoresPlayerInput = false
end

function Wheel:hasReachedLevelEnd()
	return self.hasReachedLevelEnd
end

function Wheel:setAwaitingInput() 
	self.isAwaitingInput = true
end

local previousTicks = 0
local currentTicks = 0

-- Movement

function Wheel:update()
	local input = self.input
	
	-- Update if player has died
	
	if self.y > 260 and (self.hasJustDied == false) then
		self:setIsDead()
		return
	end
	
	-- Ignore input 
	
	local crankTicks
	
	if self.ignoresPlayerInput == false then
		-- Player Input
		
		-- Has just pressed jump
		-- Is holding jump (Jump timer)

		if (playdate.buttonJustReleased(playdate.kButtonUp) or playdate.buttonJustReleased(playdate.kButtonB)) and self.isJumping then
			self:endJump()
		end
		
		if (playdate.buttonIsPressed(playdate.kButtonUp) or playdate.buttonIsPressed(playdate.kButtonB)) then
			self:applyJump()
		end
		
		if not isDPadControlsEnabled then
			crankTicks = playdate.getCrankTicks(crankTicksPerCircle)
			
			local ticks = crankTicks / 12
			currentTicks += ticks
			
			if math.abs(previousTicks - currentTicks) >= 1 then
				sampleplayer:playSample(kAssetsSounds.tick)
				previousTicks = currentTicks
			end
		else
			crankTicks = playdate.buttonIsPressed(playdate.kButtonRight) and dPadSensitivity or playdate.buttonIsPressed(playdate.kButtonLeft) and -dPadSensitivity or 0
		end
	else
		crankTicks = 0
	end
	
	local previousBounds = { self:getBounds() }
	
	if self.isFrozen == false then
		self.velocityY = math.min(self.velocityY + gravity, maxFallSpeed)
		self.velocityX = self:calculateSpeed(crankTicks, self.velocityX)
	else
		self.velocityY = 0
		self.velocityX = 0
	end
	
	-- Reset values that get re-calculated
	
	self.touchingGround = false
	self._coinCountUpdate = 0
	self._isLoadingCheckpoint = false
	
	self.normalPrevious.x = self.normal.x
	self.normalPrevious.y = self.normal.y
	
	-- Update position according to velocity
	
	local actualX, actualY, collisions, length = self:moveWithCollisions(
		self.x + self.velocityX, 
		self.y + self.velocityY
	)

	-- Collisions-based updates
	
	local normalUpdate = { x = 0, y = 0 }
	
	for _, collision in pairs(collisions) do
		local target = collision.other
		if target.type == kSpriteTypes.platform then
			if collision.normal.x ~= 0 then 
				--horizontal collision
				self.velocityX = 0
				normalUpdate.x = collision.normal.x
			end
			
			if collision.normal.y == -1 then 
				--top collision
				self.touchingGround = true
				
				self:resetJumpState()
			end
			
			if collision.normal.y ~= 0 then
				normalUpdate.y = collision.normal.y
			end
		elseif target.type == kSpriteTypes.coin then
			if target:isVisible() and self:alphaCollision(target) then
				-- Win some points
				sampleplayer:playSample("coin")
				target:isGrabbed()
				self._coinCountUpdate += 1
			end
		elseif target.type == kSpriteTypes.killBlock then
			if self:alphaCollision(target) then
				-- Die
				self:setIsDead()
			end
		elseif target.type == kSpriteTypes.checkpoint then
			if not target:isSet() then
				local progress, started, complete = target:loadCheckpoint()
				
				self._recentLoadingCheckpoint = target
				self._isLoadingCheckpoint = true
				
				self.signals.onCheckpointLoad(target.x + target.width / 2, target.y, progress, started, false, complete)
				
				if target:loadFinished() == true then
					target:set()
					
					self.hasTouchedNewCheckpoint = true
					self._recentCheckpoint = {x = target.x, y = target.y}
					
					self.signals.onTouchCheckpoint(target.x + target.width / 2, target.y)
				end
			end
		elseif target.type == kSpriteTypes.levelEnd then
			if self:alphaCollision(target) then
				if self.hasReachedLevelEnd then
					self.signals.onLevelComplete()
				end
				
				self.hasReachedLevelEnd = true
			end
		end
	end
	
	if self._recentLoadingCheckpoint ~= nil and self._isLoadingCheckpoint == false then
		-- Cancel loading checkpoint
		self._recentLoadingCheckpoint:stopLoading()
		self._recentLoadingCheckpoint = nil
		
		self.signals.onCheckpointLoad(nil, nil, nil, nil, true, nil)
	end
	
	if self.hasJustDied == false then	
		self.normal.x = normalUpdate.x
		self.normal.y = normalUpdate.y
		
		if self.normal.x ~= 0 and self.normalPrevious.x == 0 then
			sampleplayer:playSample("bump")
		end
		
		if self.normal.y == -1 and self.normalPrevious.y == 0 then
			sampleplayer:playSample("land")
		end
		
		if self.normal.y == 1 and self.normalPrevious.y == 0 then
			sampleplayer:playSample("bump")
		end
		
		-- Play sounds based on movement
		local maxVelocityX = 11 -- this has been copied from speed.lua
		local velocityFactor = math.abs(self.velocityX) / maxVelocityX
		
		local frequencyFactor = (velocityFactor + 1) * 2.5
		local volumeFactor = (velocityFactor + 1)
		
		synth:play(kAssetsSounds.rev, frequencyFactor, volumeFactor)
	end
	
	-- Update graphics
	
	self.angle = self.angle - self.velocityX / 5
	
	if self.angle > 12 then 
		self.angle = self.angle % 12 
	end
	if self.angle < 1 then 
		self.angle += 12 
	end
	
	local imageIndex = math.floor(self.angle)

	self:setImage(self.imagetable[imageIndex])
	
	local currentBounds = { self:getBounds() }
	if (previousBounds[1] ~= currentBounds[1]) or 
		(previousBounds[2] ~= currentBounds[2]) or 
		(previousBounds[3] ~= currentBounds[3]) or 
		(previousBounds[4] ~= currentBounds[4]) then
		local drawOffsetX, _ = gfx.getDrawOffset()
		gfx.sprite.addDirtyRect(previousBounds[1] + drawOffsetX, previousBounds[2], previousBounds[3], previousBounds[4])
		gfx.sprite.addDirtyRect(currentBounds[1] + drawOffsetX, currentBounds[2], currentBounds[3], currentBounds[4])
	end
end

-- Movement / Speed

function Wheel:calculateSpeed(crankTicks, speedPreviousActual)
	local crankTicks = crankTicks * crankTickMultiplier
	
	-- Handle update manual
	
	local speedManualBounded = math.clamp(crankTicks, -maxSpeedManual, maxSpeedManual)
	local speedPreviousBounded = math.clamp(speedPreviousActual, -maxSpeedManual, maxSpeedManual)
	local speedManualActual = math.approach(
		speedPreviousBounded, 
		speedManualBounded, 
		accelerationManual
	)
	
	-- Handle speed-up
	
	local speedUpActual = 0
	
	if math.abs(speedPreviousActual) >= maxSpeedManual then
		local speedUpPreviousActual = math.sign(speedPreviousActual) * (math.abs(speedPreviousActual) - maxSpeedManual)
		
		if math.sign(speedManualActual) == math.sign(speedPreviousActual) then
			-- Apply Speed up
			
			speedUpActual = speedUpPreviousActual + crankTicks * speedUpAcceleration 
		end
	end
	
	-- Assign actual speed
	
	local speedActual = speedManualActual + speedUpActual
	
	-- Return speed limited by max speed
	
	if speedActual < 0 then
		return math.max(speedActual, -maxVelocityX)
	else 
		return math.min(speedActual, maxVelocityX)
	end
end

-- Jump

function Wheel:resetJumpState()
	self.isJumping = false
	self.hasJumpedFinished = false
	self.jumpTimeInTicks = 0
end

function Wheel:applyJump()
	if self.hasJumpedFinished then
		return
	end
	
	self.isJumping = self.touchingGround or self.jumpTimeInTicks > 0
	
	if self.isJumping then
		self.jumpTimeInTicks += 1
		
		if self.touchingGround then
			self.velocityY = -jumpSpeed
			
			sampleplayer:playSample("jump")
		end
	end
	
	if self.jumpTimeInTicks > jumpMaxTicks then
		self.hasJumpedFinished = true
	end
end

function Wheel:endJump()	
	if self.isJumping and self.jumpTimeInTicks < smallJumpMaxTicks then
		self.velocityY = -smallJumpSpeed
	end
	
	self.isJumping = false
	self.hasJumpedFinished = true
end

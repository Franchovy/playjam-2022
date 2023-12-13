import "engine"
import "constant"
import "utils/images"
import "playdate"

class("Wheel").extends(playdate.graphics.sprite)

import "speed"
import "sounds"
import "jump"

local maxFallSpeed = 14
local gravity = 1.4
local scorePerCoin = 10
local crankTicksPerCircle = 72
local images = {}

function Wheel.new() 
	return Wheel()
end

function Wheel:init()
	Wheel.super.init(self)
	
	self.imagetable = playdate.graphics.imagetable.new(kAssetsImages.wheel)
	
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
	
	self:initializeSamples()
	sampleplayer:addSample(kAssetsSounds.tick, kAssetsSounds.tick, 0.2)
	
	-- Create Properties
	
	self:resetValues()
	self:resetJumpState()
end

function Wheel:resetValues() 
	self.velocityX = 0
	self.velocityY = 0
	self.angle = 0
	self.hasJustDied = false
	self.isAwaitingInput = false
	self.score = 0
	self.ignoresPlayerInput = true
	self.hasReachedLevelEnd = false
	self.hasTouchedNewCheckpoint = false
	self.hasJustTouchedGround = false
	self._recentCheckpoint = nil
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
	
	local random = math.random(2)
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

		if (playdate.buttonJustReleased(playdate.kButtonUp) or playdate.buttonJustReleased(playdate.kButtonB)) and self:isJumping() then
			self:endJump()
		end
		
		if (playdate.buttonIsPressed(playdate.kButtonUp) or playdate.buttonIsPressed(playdate.kButtonB)) then
			self:applyJump()
		end
		
		crankTicks = playdate.getCrankTicks(crankTicksPerCircle)
		
		local ticks = crankTicks / 12
		currentTicks += ticks
		
		if math.abs(previousTicks - currentTicks) >= 1 then
			sampleplayer:playSample(kAssetsSounds.tick)
			previousTicks = currentTicks
		end
	else
		crankTicks = 0
	end
	
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
				target:set()
				self.hasTouchedNewCheckpoint = true
				self._recentCheckpoint = {x = target.x, y = target.y}
				
				self.signals.onTouchCheckpoint()
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
		self:playMovementSound()
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
end

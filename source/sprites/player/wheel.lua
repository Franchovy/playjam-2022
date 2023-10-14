import "engine"
import "constant/images"
import "constant/collisionGroups"
import "constant/spriteTypes"
import "playdate"

class("Wheel").extends(Sprite)

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
	
	images = getImageTable(kImages.wheel, 12)
	self:setImage(images[1])
	self:setCenter(0, 0)
	
	self.type = spriteTypes.player
	
	self:setCollideRect(self:getBounds())
	
	self.collisionResponse = function(self, other)
		if other.type == spriteTypes.platform then
			return kCollisionResponse.slide
		end
		
		return kCollisionResponse.overlap
	end
	
	-- Samples
	
	self:initializeSamples()
	
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
	self.currentWindPower = 0
	self.ignoresPlayerInput = true
	self.hasReachedLevelEnd = false
end

function Wheel:setIsDead() 
	if self.hasJustDied then
		return
	end
	
	self.ignoresPlayerInput = true
	self.hasJustDied = true
	sampleplayer:playSample("hurt")
end

function Wheel:startGame()
	self.ignoresPlayerInput = false
end

-- Movement

function Wheel:update()
	
	-- Update if player has died
	
	if self.y > 260 then
		self:setIsDead()
		return
	end
	
	-- Ignore input 
	
	if self.ignoresPlayerInput then
		return
	end
	
	-- Player Input
	
	-- Has just pressed jump
	-- Is holding jump (Jump timer)

	if buttons.isUpButtonJustReleased() and self:isJumping() then
		self:endJump()
	end
	
	if buttons.isUpButtonPressed() then
		self:applyJump()
	end
	
	self.velocityY = math.min(self.velocityY + gravity, maxFallSpeed)
	
	-- Update velocity according to acceleration
	
	local crankTicks = playdate.getCrankTicks(crankTicksPerCircle)
	
	self.velocityX = self:calculateSpeed(crankTicks, self.velocityX)
	
	-- Apply wind power
	
	self.velocityX += self.currentWindPower
	
	-- Reset values that get re-calculated
	
	self.currentWindPower = 0
	self.touchingGround = false
	
	-- Update position according to velocity
	
	local actualX, actualY, collisions, length = self:moveWithCollisions(
		self.x + self.velocityX, 
		self.y + self.velocityY
	)

	-- Collisions-based updates
	
	for _, collision in pairs(collisions) do
		local target = collision.other
		if target.type == spriteTypes.platform then
			if collision.normal.x ~= 0 then 
				--horizontal collision
				self.velocityX = 0
			end
			if collision.normal.y == -1 then 
				--top collision
				self.touchingGround = true
				
				self:resetJumpState()
			end
		elseif target.type == spriteTypes.coin then
			if target:isVisible() and self:alphaCollision(target) then
				-- Win some points
				self:onGrabbedCoin(target)
			end
		elseif target.type == spriteTypes.killBlock then
			if self:alphaCollision(target) then
				-- Die
				self:setIsDead()
			end
		elseif target.type == spriteTypes.wallOfDeath then
			self:setIsDead()
		elseif target.type == spriteTypes.checkpoint then
			if not target:isSet() then
				target:set()
			end
		elseif target.type == spriteTypes.wind then
			self.currentWindPower += target.windPower
		elseif target.type == spriteTypes.levelEnd then
			if self:alphaCollision(target) then
				-- Die
				self.hasReachedLevelEnd = true
			end
		end
	end
	
	-- Play sounds based on movement
	self:playMovementSound()
	
	self:playWindBasedSounds()
	
	-- Update graphics
	
	self.angle = self.angle - self.velocityX / 5
	
	if self.angle > 12 then 
		self.angle = self.angle % 12 
	end
	if self.angle < 1 then 
		self.angle += 12 
	end
	
	local imageIndex = math.floor(self.angle)

	self:setImage(images[imageIndex])
end

function Wheel:hasReachedLevelEnd()
	return self.hasReachedLevelEnd
end

function Wheel:setAwaitingInput() 
	self.isAwaitingInput = true
end

function Wheel:getScoreText()
	return "Score: ".. self.score
end

function Wheel:onGrabbedCoin(coin)
	self.score += scorePerCoin
	sampleplayer:playSample("coin")
	
	coin:isGrabbed()
end



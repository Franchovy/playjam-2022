import "engine"
import "components/images"

-- Params
local jumpSpeed = 22
local hopSpeed = 16
local gravity = 2.1
local scorePerCoin = 10
local maxFallSpeed = 16

-- Params, not to modify
local crankTicksPerCircle = 36

class("Wheel").extends(Sprite)

import "speed"
import "sounds"

function Wheel.new() 
	return Wheel()
end

function Wheel:init()
	Wheel.super.init(self)
	
	self:setImage(kImages.wheel, 1)
	
	self.type = spriteTypes.player
	
	local marginSize = 3
	self:setCollideRect(
		marginSize, 
		marginSize, 
		self:getSize() - marginSize * 2, 
		self:getSize() - marginSize * 2
	)
	
	-- Collisions Response
	
	self:setCollidesWith(spriteTypes.platform, collisionTypes.slide)
	self:setCollidesWith(spriteTypes.coin, collisionTypes.overlap)
	self:setCollidesWith(spriteTypes.killBlock, collisionTypes.overlap)
	self:setCollidesWith(spriteTypes.wind, collisionTypes.overlap)
	
	self:activateCollisionResponse()
	
	self:initializeSamples()
	
	-- Create Properties
	
	self:resetValues()
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
	self.hasDoubleJumped = false
end

function Wheel:setIsDead() 
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
	
	local hasJumped = buttons.isUpButtonJustPressed()
	
	-- Update push vector based on crank ticks
		
	if hasJumped and (not self.hasDoubleJumped) then
		if self.touchingGround then
			self.velocityY = -jumpSpeed
		else
			self.velocityY = -hopSpeed
			self.hasDoubleJumped = true
		end
	end
	
	self.velocityY = math.min(self.velocityY + gravity, maxFallSpeed)
	
	-- Update velocity according to acceleration
	
	local crankTicks = playdate.getCrankTicks(crankTicksPerCircle)
	
	self.velocityX = self:calculateSpeed(crankTicks, self.velocityX)
	
	-- Apply wind power
	
	self.velocityX += self.currentWindPower
	
	-- Update position according to velocity
	local actualX, actualY, collisions, length = self:moveWithCollisions(
		self.x + self.velocityX, 
		self.y + self.velocityY
	)

	-- Reset values
	
	self:resetValuesBeforeCollisionUpdate()
	
	-- Collisions-based updates
	
	local collisions = collisionHandler:getCollisionsForSprite(self)
	
	for target, collision in pairs(collisions) do
		if target.type == spriteTypes.platform then
			if collision.normal.x ~= 0 then 
				if collision.normal.x > 0 then
					--print("Move left")
				elseif collision.normal.x < 0 then
					--print("Move right: ".. target.velocity.x)
				end
				--horizontal collision
				self.velocityX = 0
			end
			if collision.normal.y == -1 then 
				--top collision
				self.touchingGround = true
				self.hasDoubleJumped = false
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
		elseif target.type == spriteTypes.wind then
			self.currentWindPower += target.windPower
		end
	end
	
	-- Play sounds based on movement
	self:playMovementSound()
	
	self:playLandingBasedSound()
	self:playWindBasedSounds()
	
	-- Update graphics
	
	self.angle = self.angle + self.velocityX / 10
	if self.angle > 12 then self.angle = self.angle % 12 end
	if self.angle < 1 then self.angle += 12 end
	local imageIndex = math.floor(self.angle)

	self:setImage(kImages.wheel, imageIndex)
end

function Wheel:resetValuesBeforeCollisionUpdate()
	self.currentWindPower = 0
	self.touchingGround = false
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

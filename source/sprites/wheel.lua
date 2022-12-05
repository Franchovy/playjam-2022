import "engine"

-- Params
local jumpSpeed = 18
local hopSpeed = 12
local gravity = 2.1
local scorePerCoin = 10
local maxFallSpeed = 16
local speedBoost = 3
local velocityDragStep = 0.1
local velocityBrakeStep = 0.4
local maxVelocityX = 3

-- Params, not to modify
local crankTicksPerCircle = 36

class("Wheel").extends(Sprite)

function Wheel.new(image) 
	return Wheel(image)
end

function Wheel:init(image)
	Wheel.super.init(self, image)
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
	
	-- Load sound assets
	
	sampleplayer:addSample("jump", "sfx/jump")
	sampleplayer:addSample("drop", "sfx/drop")
	
	-- Create Properties
	
	self:resetValues()
end

function Wheel:resetValues() 
	self.velocityX = 0
	self.velocityY = 0
	self.currentVelocityDrag = 0
	self.angle = 0
	self.horizontalAcceleration = 0
	self.hasJustDied = false
	self.isAwaitingInput = false
	self.score = 0
	self.currentWindPower = 0
end

function Wheel:setIsDead() 
	self.hasJustDied = true
	sampleplayer:playSample("drop")	
end

function Wheel:startGame()
		
end

-- Movement

function Wheel:update()
	
	if self.isAwaitingInput then
		-- Activate only if the jump button is pressed
		if buttons.isUpButtonPressed() then
			self.isAwaitingInput = false
		else 
			return
		end
	end
	
	-- Update if player has died
	
	if self.y > 260 then
		self:setIsDead()
		return
	end
	
	-- Player Input
	
	local hasJumped = buttons.isUpButtonJustPressed()
	local crankTicks = playdate.getCrankTicks(crankTicksPerCircle)
	local isBraking = (crankTicks > 0) ~= (self.velocityX > 0)
		
	-- Update push vector based on crank ticks
		
	if hasJumped then
		if self.touchingGround then
			self.velocityY = -jumpSpeed
		else
			self.velocityY = -hopSpeed
		end
		sampleplayer:playSample("jump")
	end
	
	-- Update velocity according to acceleration
	
	self.velocityX = self:calculateSpeed(crankTicks, isBraking)
	self.velocityY = math.min(self.velocityY + gravity, maxFallSpeed)
	
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
				--horizontal collision
				self.velocityX = 0
			end
			if collision.normal.y == -1 then 
				--top collision
				self.touchingGround = true
			end
		elseif target.type == spriteTypes.coin then
			if target:isVisible() and self:alphaCollision(target) then
				-- Win some points
				self:increaseScore()
				target:isGrabbed()
			end
		elseif target.type == spriteTypes.killBlock then
			if self:alphaCollision(target) then
				-- Die
				self:setIsDead()
			end
		elseif target.type == spriteTypes.wind then
			self.currentWindPower += target.windPower
		end
	end
	
	-- Update graphics
	
	self.angle = self.angle + self.velocityX / 10
	if self.angle < 1 then self.angle = 6 end
	if self.angle > 6 then self.angle = 1 end
	local imageName = string.format("images/wheel%01d", math.floor(self.angle))
	
	self:getImage():load(imageName)
end

function Wheel:resetValuesBeforeCollisionUpdate()
	self.currentWindPower = 0
	self.touchingGround = false
end

function Wheel:calculateSpeed(crankTicks, isBraking)
	if isBraking then
		-- Apply brakes (slow down faster)
		self.currentVelocityDrag = math.approach(self.currentVelocityDrag, 0, velocityBrakeStep)
	else
		-- Apply wheel momentum to velocity drag
		self.currentVelocityDrag = math.approach(self.currentVelocityDrag, self.velocityX, velocityDragStep)
	end
	
	-- Handle moving forward
	local rawVelocityX = crankTicks * speedBoost + self.currentVelocityDrag

	-- Add a drag to velocity if above the max speed	
	if rawVelocityX > maxVelocityX then
		return math.approach(rawVelocityX, maxVelocityX, 0.2) 
	else
		return rawVelocityX	 
	end
end

function Wheel:setAwaitingInput() 
	self.isAwaitingInput = true
end

function Wheel:getScoreText()
	return "Score: ".. self.score
end

function Wheel:increaseScore()
	print("increase score")
	self.score += scorePerCoin
end

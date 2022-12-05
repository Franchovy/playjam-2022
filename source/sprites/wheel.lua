import "engine"

class("Wheel").extends(Sprite)

function Wheel.new(image) 
	return Wheel(image)
end

function Wheel:init(image)
	Wheel.super.init(self, image)
	self.type = spriteTypes.player

	self.score=0--new

	self.isInWind=false
	self.currentWindPower=0
	
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

local maxFallSpeed = 12
local crankTicksPerCircle = 36
local angle = 1
local velocityDrag = 0

function Wheel:setIsDead() 
	if self.isDead then
		self.hasJustDied = false
	else 
		self.hasJustDied = true
		self.isDead = true	
		
		sampleplayer:playSample("drop")
	end
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
	
	if self.y > 260 or self.isDead then
		self:setIsDead()
		return
	end
	
	-- Player Input
	
	local crankTicks = playdate.getCrankTicks(crankTicksPerCircle)
	local hasJumped = buttons.isUpButtonJustPressed()
		
	-- Update push vector based on crank ticks
		
	if hasJumped then
		self.velocityY = -10
		sampleplayer:playSample("jump")
	end
	
	-- Update velocity according to acceleration
	
	velocityDrag = self.velocityX * 0.2
	self.velocityX = crankTicks * 2.5 + velocityDrag +self.currentWindPower
	self.velocityY = math.min(self.velocityY + gravity, maxFallSpeed)
	
	-- Update position according to velocity
	local actualX, actualY, collisions, length = self:moveWithCollisions(
		self.x + self.velocityX, 
		self.y + self.velocityY
	)

	self.currentWindPower=0
	
	-- Collisions-based updates
	
	local collisions = collisionHandler:getCollisionsForSprite(self)
	
	for target, collision in pairs(collisions) do
		print("collision handle")
		if target.type == spriteTypes.platform then
			print("platform")
			if self:alphaCollision(target) then
				print("alpha collision")
				-- Kill only if touching on the side
				-- TODO: - Calculate using normal
				--self:setIsDead()
			end
		elseif target.type == spriteTypes.coin then
			-- Win some points
			self:increaseScore()
		elseif target.type == spriteTypes.killBlock then
			print("kill block")
			if self:alphaCollision(target) then
				-- Die
				print("alpha collision")
				self:setIsDead()
			end
		elseif target.type == spriteTypes.wind then
			self.currentWindPower += target.windPower
		end
	end
	
	-- Update graphics
	
	angle = angle + self.velocityX / 10
	if angle < 1 then angle = 6 end
	if angle > 6 then angle = 1 end
	local imageName = string.format("images/wheel%01d", math.floor(angle))
	
	self:getImage():load(imageName)
end

function Wheel:setAwaitingInput() 
	self.isAwaitingInput = true
end

function Wheel:resetValues() 
	self.velocityX = 0
	self.velocityY = 0
	self.horizontalAcceleration = 0
	self.isDead = false
	self.hasJustDied = false
	self.isAwaitingInput = false
end

function Wheel:getScoreText()
	return "Score: ".. self.score
end

function Wheel:increaseScore()
	self.score=self.score+1
end

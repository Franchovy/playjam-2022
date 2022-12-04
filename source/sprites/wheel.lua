import "engine"

class("Wheel").extends(gfx.sprite)

function Wheel.new(image) 
	return Wheel(image)
end

function Wheel:init(image)
	Wheel.super.init(self, image)
	self.type = "Wheel"

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
	
	collisionHandler:setCollidesForObject(self, spriteTypes.platform, collisionTypes.slide)
	collisionHandler:setCollidesForObject(self, spriteTypes.coin, collisionTypes.overlap)
	collisionHandler:setCollidesForObject(self, spriteTypes.killBlock, collisionTypes.freeze)
	collisionHandler:setCollidesForObject(self, spriteTypes.wind, collisionTypes.overlap)
	
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

	--self:setInWind(false,0)
	self.currentWindPower=0
	
	-- Update collisions
	
	local collisions = collisionHandler:getCollisionsFor(self)
	
	for targetType, collisionType in collisions do
		if targetType == spriteTypes.platform then
			-- Kill only if touching on the side
			if self:alphaCollision(collision.other) then
			-- Kill player if touched
			self:setIsDead()
			
		elseif targetType == spriteTypes.coin then
			-- Win some points
		elseif targetType == spriteTypes.killBlock then
			-- Die
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

function Wheel:increaseScore() --new
	self.score=self.score+1
	--print("increaseScore")
	print(self.score)
end

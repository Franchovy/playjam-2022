import "engine"

class("Wheel").extends(gfx.sprite)

function Wheel.new(image) 
	return Wheel(image)
end

function Wheel:init(image)
	Wheel.super.init(self, image)
	self.type = "Wheel"

	self.score=0--new
	
	local marginSize = 3
	self:setCollideRect(
		marginSize, 
		marginSize, 
		self:getSize() - marginSize * 2, 
		self:getSize() - marginSize * 2
	)
	self:add()
	
	-- Collisions Response
	
	function self:collisionResponse (other)
		if other.type == "Floor" then
			return collisionTypes.slide
		end
		return collisionTypes.overlap
	end
	
	-- Load sound assets
	self.sampleplayer = {
		jump = sound.sampleplayer.new("sfx/jump"),
		drop = sound.sampleplayer.new("sfx/drop")
	}
	
	-- Create Properties
	
	self:resetValues()
end

local maxFallSpeed = 12
local crankTicksPerCircle = 36
local angle = 1
local velocityDrag = 0

function Wheel:setIsDead() 
	--print("Set is dead") -new
	if self.isDead then
		self.hasJustDied = false
	else 
		self.hasJustDied = true
		self.isDead = true	
	end
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
		self.sampleplayer.jump:play()
	end
	
	-- Update velocity according to acceleration
	
	velocityDrag = self.velocityX * 0.2
	
	self.velocityX = crankTicks * 2.5 + velocityDrag
	self.velocityY = math.min(self.velocityY + gravity, maxFallSpeed)
	
	-- Update position according to velocity
	local actualX, actualY, collisions, length = self:moveWithCollisions(
		self.x + self.velocityX, 
		self.y + self.velocityY
	)
	
	table.each(collisions,
		function (collision)
			if collision.other.type ~= nil and
				collision.other.type == "Floor" then
				self:setIsDead()
				self.sampleplayer.drop:play()
			elseif collision.other.type ~= nil and --new
				collision.other.type == "Coin" then
					self:increaseScore()
					collision.other:destroy()
			end
		end
	)
	
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

function Wheel:increaseScore() --new
	self.score=self.score+1
	--print("increaseScore")
	print(self.score)
end
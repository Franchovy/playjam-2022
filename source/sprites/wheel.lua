import "engine"

class("Wheel").extends(gfx.sprite)

function Wheel.new(image) 
	return Wheel(image)
end

function Wheel:init(image)
	Wheel.super.init(self, image)
	self.type = "Wheel"
	
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
	
	-- Create Properties
	
	self.velocityX = 0
	self.velocityY = 0
end

local maxFallSpeed = 12
local crankTicksPerCircle = 36
local angle = 1


-- Movement

function Wheel:update()
	
	-- Player Input
	
	local crankTicks = playdate.getCrankTicks(crankTicksPerCircle)
	local hasJumped = buttons.isUpButtonJustPressed()
		
	-- Update push vector based on crank ticks
		
	if hasJumped then
		self.velocityY = -10
	end
	
	-- Update velocity according to acceleration
	self.velocityX = crankTicks
	self.velocityY = math.min(self.velocityY + gravity, maxFallSpeed)
	
	-- Update position according to velocity
	local actualX, actualY, collisions, length = self:moveWithCollisions(
		self.x + self.velocityX, 
		self.y + self.velocityY
	)
	
	-- Update graphics
	
	angle = angle + self.velocityX / 10
	if angle < 1 then angle = 6 end
	if angle > 6 then angle = 1 end
	local imageName = string.format("images/wheel%01d", math.floor(angle))
	
	self:getImage():load(imageName)
	
	-- update screen position
	
	local drawOffset = gfx.getDrawOffset()
	print(drawOffset)
	
	if self.x > 150 then
		gfx.setDrawOffset(-actualX + 150, 0)
	end


end

local isTouchingFloor = false

function Wheel:setIsTouchingFloor(value) 
	isTouchingFloor = value
end

function Wheel:isTouchingFloor()
	return isTouchingFloor
end
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
	self:setCenter(
		0.5,
		0.5 
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

local crankTicksPerCircle = 12
local angle = 1

-- Movement

function Wheel:update()
	-- Move according to vectors	
	
	local crankTicks = playdate.getCrankTicks(crankTicksPerCircle)
	
	-- Update push vector based on crank ticks
	
	local rotation = crankTicks % 4
	
	angle = angle + crankTicks
	if angle < 1 then angle = 6 end
	if angle > 6 then angle = 1 end
		
	self:getImage():load("images/wheel"..angle)
	
	-- Update velocity according to acceleration
	self.velocityX = self.velocityX + crankTicks * 6
	
	-- if not self:isTouchingFloor() then
		self.velocityY = math.max(self.velocityY + gravity, maxFallSpeed)
	-- end
	
	-- Update position according to velocity
	local actualX, actualY, collisions, length = self:moveWithCollisions(
		self.x + self.velocityX, 
		self.y + self.velocityY
	)
	
	if #collisions > 0 then
		-- Update forces based on collisions
		local ownCollisions = table.each(
				collisions,
				function (collision) 
					return collision.sprite ~= self and collision.type == collisionTypes.slide
				end
			)
			
		local filteredCollisions = table.filter(collisions)
		
		if #filteredCollisions > 0 then
			local collisionData = filteredCollisions[1]
			-- Update velocity to reflect real velocity
			self.velocityX = collisionData.move.x		
			self.velocityY = collisionData.move.y
			
			self:setIsTouchingFloor(collisionData.normal.y == -1.0)
			
			-- Translate X velocity into Y velocity
			if collisionData.normal.y ~= 0 then
				local speedToRotate = self.velocityX * 0.1
				self.velocityY = self.velocityY - speedToRotate
				self.velocityX = self.velocityX - speedToRotate
			end
		end
	end
end

local isTouchingFloor = false

function Wheel:setIsTouchingFloor(value) 
	isTouchingFloor = value
end

function Wheel:isTouchingFloor()
	return isTouchingFloor
end
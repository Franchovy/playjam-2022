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

local gravityVector = geometry.vector2D.new(0, 1)
local normalVector = geometry.vector2D.new(0, 0)
local pushVector = geometry.vector2D.new(0, 0)
local resistanceVector = geometry.vector2D.new(0, 0)

local crankTicksPerCircle = 12
-- Movement

function Wheel:update()
	-- Move according to vectors	
	
	local crankTicks = playdate.getCrankTicks(crankTicksPerCircle)
	local angle = crankTicks * 2 * 3.14 / crankTicksPerCircle
	
	-- Update push vector based on crank ticks
	
	self:setRotation(angle)
	
	-- Todo: triangulate on normal | (v -> 0 (x), >| -> 90 (y), ^ -> 180 (-x), |< -> 270 (-y))
	pushVector.x = crankTicks
	
	-- Calculate resistance (friction) vectors based on normals

	resistanceVector.x = self.velocityX * -normalVector.y
	resistanceVector.y = self.velocityY * -normalVector.x
		
	-- Update velocity according to acceleration
	self.velocityX = self.velocityX + gravityVector.x + normalVector.x + pushVector.x - resistanceVector.x
	self.velocityY = self.velocityY + gravityVector.y + normalVector.y + pushVector.y - resistanceVector.y
	
	print("--------")
	print("Vectors:")
	print("g:"..gravityVector.x..","..gravityVector.y)
	print("n:"..normalVector.x..","..normalVector.y)
	print("p:"..pushVector.x..","..pushVector.y)
	print("r:"..-resistanceVector.x..","..-resistanceVector.y)
	
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
			
			normalVector.x = (normalVector.x + collisionData.normal.x) / 2
			normalVector.y = (normalVector.y + collisionData.normal.y) / 2
		end
	end
end
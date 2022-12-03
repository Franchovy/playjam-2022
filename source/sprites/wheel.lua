import "engine"

class("Wheel").extends(gfx.sprite)

function Wheel.new() 
	return Wheel()
end

function Wheel:init()
	local image = gfx.image.new("images/wheel2")
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

-- Movement

function Wheel:update()
	-- Move according to vectors	
	local crankTicks = playdate.getCrankTicks(12)
	
	pushVector.x = crankTicks
	
	-- Calculate resistance (friction) vectors based on normals

	resistanceVector.x = self.velocityX * -normalVector.y * 0.3
		
	-- Update velocity according to acceleration
	self.velocityX = self.velocityX + gravityVector.x + normalVector.x + pushVector.x - resistanceVector.x
	self.velocityY = self.velocityY + gravityVector.y + normalVector.y + pushVector.y - resistanceVector.y
	
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
			
			normalVector.x = collisionData.normal.x
			normalVector.y = collisionData.normal.y
		end
	end
end
import "CoreLibs/object"
import "CoreLibs/sprites"
import "collisionhandler"

local gfx <const> = playdate.graphics

class("Sprite").extends(gfx.sprite)

-- ===============
-- ---------------
-- Overrides

function Sprite:init(image)
	Sprite.super.init(self, image)
	
	self.type = "unset"
end

-- Global sprite update function
function Sprite.update()
	Sprite.super.update()
	
	collisionHandler:update()
end

--------------------
-- Custom methods

function Sprite:activateCollisionResponse() 
	collisionHandler:activateCollisionResponsesForSprite(self)
end

-- ========================= --
-- Collision Handler Methods --

function Sprite:getCollisions()
	collisionHandler:getCollisionsForSprite(self)
end

function Sprite:activateCollisionResponse()
	collisionHandler:activateCollisionResponsesForSprite(self)
end

function Sprite:setCollidesWith(otherType, collisionResponseType)
	collisionHandler:setCollidesForSprite(self, otherType, collisionResponseType)
end

-----------------------------------------------
-- MoveWithCollisions, CheckCollisions override

function Sprite:moveWithCollisions(goalX, goalY)
	-- Case if (x,y) is passed in as a point
	if goalY == nil then
		goalX, goalY = goalX.x, goalX.y
	end
	
	-- Super moveWithCollisions call
	local actualX, actualY, collisions, length = gfx.sprite.moveWithCollisions(self, goalX, goalY)
	
	-- Update collisions
	collisionHandler:updateCollisionForSprite(self, collisions)
	
	return actualX, actualY, collisions, length
end

function Sprite:checkCollisions(goalX, goalY)
	-- Case if (x,y) is passed in as a point
	if goalY == nil then
		goalX, goalY = goalX.x, goalX.y
	end
	
	-- Super moveWithCollisions call
	local actualX, actualY, collisions, length = gfx.sprite.checkCollisions(self, goalX, goalY)
	
	-- Update collisions
	collisionHandler:updateCollisionForSprite(self, collisions)
	
	return actualX, actualY, collisions, length
end

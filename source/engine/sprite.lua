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

function Sprite.update()
	Sprite.super.update(self)
	
	collisionHandler:update()
end

--------------------
-- Custom methods

function Sprite:activateCollisionResponse() 
	collisionHandler:activateCollisionsResponsesForSprite(self)
end

-- ========================= --
-- Collision Handler Methods --

function Sprite:getCollisions()
	collisionHandler:getCollisionsForSprite(self)
end

function Sprite:activateCollisionsResponse()
	collisionHandler:activateCollisionsResponsesForSprite(self)
end

function Sprite:setCollidesWith(otherType, collisionResponseType)
	collisionHandler:setCollidesForSprite(self, otherType, collisionResponseType)
end

-----------------------------------------------
-- MoveWithCollisions, CheckCollisions override

function Sprite:moveWithCollisions(goalX, goalY)
	local actualX, actualY, collisions, length = gfx.sprite.moveWithCollisions(self, goalX, goalY)
	
	collisionHandler:updateCollisionForSprite(self, collisions)
	
	return actualX, actualY, collisions, length
end

function Sprite:checkCollisions(goalX, goalY)
	local actualX, actualY, collisions, length = gfx.sprite.checkCollisions(self, goalX, goalY)
	
	collisionHandler:updateCollisionForSprite(self, collisions)
	
	return actualX, actualY, collisions, length
end

-- Same functions with goal point

function Sprite:moveWithCollisions(goalPoint)
	local actualX, actualY, collisions, length = gfx.sprite.moveWithCollisions(self, goalPoint)
	
	collisionHandler:updateCollisionForSprite(self, collisions)
	
	return actualX, actualY, collisions, length
end

function Sprite:checkCollisions(goalPoint)
	local actualX, actualY, collisions, length = gfx.sprite.checkCollisions(self, goalPoint)
	
	collisionHandler:updateCollisionForSprite(self, collisions)
	
	return actualX, actualY, collisions, length
end
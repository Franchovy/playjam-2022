import "CoreLibs/object"
import "CoreLibs/sprites"
import "collisionhandler"

local gfx <const> = playdate.graphics

class("Sprite").extends(gfx.sprite)

-- Super override methods

function Sprite.update()
	gfx.sprite.update()
	
	collisionHandler:update()
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
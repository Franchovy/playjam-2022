import "engine"
import "constant/images"
import "constant/spriteTypes"
import "constant/collisionGroups"

class('Platform').extends(Sprite)

-------------------------
-- Structs

directions = {
	left = {-1, 0},
	right = {1, 0},
	up = {0, -1},
	down = {0, 1}
}

-----------------------
-- Constants

local MAX_SPEED = 1
local TIMER_LENGTH = 75

-----------------------
-- Private properties


function Platform:timerCallback()
	if self.velocity.x > 0 then
		self.velocity.x = -MAX_SPEED
	elseif self.velocity.x < 0 then
		self.velocity.x = MAX_SPEED
	end
	
	--direction = invertedDirection(direction)
end

function Platform:createTimer()
	self.movementTimer = frameTimer.new(TIMER_LENGTH, Platform.timerCallback, self)
	self.movementTimer.repeats = true
end

----------------
-- Initializer

function Platform.new(width, height, isMoving) 
	return Platform(width, height ,isMoving)
end

function Platform:init(width, height, isMoving)
	Platform.super.init(self, gfx.image.new(width, height))
	self.type = spriteTypes.platform
	self.canMove=isMoving
	self.currentOffset=0
	self.goLeft=true
	self.currentMove=0
	self.initPosX, self.initPosY=self:getPosition()
	self.movementTimer = nil
	
	----------------
	-- Draw Graphics
	
	local image = gfx.image.new("images/sprites/platform")
	self:setImage(image)
	self:setCollideRect(0, 0, self:getSize())
	self:setGroups(collisionGroups.static)
	
	----------------
	-- Set up Sprite
	
	self:setCollideRect(0, 0, self:getSize())
	self:setCenter(0, 0)
	
	-- DEBUG
	self.canMove = false
	
	if self.canMove then
		self.velocity = {
			y = 0,
			x = MAX_SPEED
		}
	else
		self.velocity = {
			y = 0,
			x = 0
		}
	end
end

--------------------
-- Update methods

function Platform:move()
	local x, y = self:getPosition()
	self:moveTo(
		x + self.velocity.x,
		y + self.velocity.y
	)
end

function Platform:update()
	if self.movementTimer == nil then
		self:createTimer()
	end
	
	self:move()
end
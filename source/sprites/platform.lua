import "engine"

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
	printTable(self.velocity)
	if self.velocity.x > 0 then
		self.velocity.x = -MAX_SPEED
	elseif self.velocity.x < 0 then
		self.velocity.x = MAX_SPEED
	end
	printTable(self.velocity.x)
	--direction = invertedDirection(direction)
end

function Platform:createTimer()
	self.movementTimer = frameTimer.new(TIMER_LENGTH, Platform.timerCallback, self)
	self.movementTimer.repeats = true
end

----------------
-- Initializer

function Platform.new(image,canMove) 
	return Platform(image,canMove)
end

function Platform:init(image,canMove)
	Platform.super.init(self, image)
	self.type = spriteTypes.platform
	self.canMove=canMove
	self.currentOffset=0
	self.goLeft=true
	self.currentMove=0
	self.initPosX, self.initPosY=self:getPosition()
	self.movementTimer = nil
	
	----------------
	-- Draw Graphics
	
	self:drawSelf()
	
	----------------
	-- Set up Sprite
	
	self:setCollideRect(0, 0, self:getSize())
	self:setCenter(0, 0)
	
	if canMove then
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
	printTable(self.velocity)
end

--------------------
-- Draw methods

function Platform:drawSelf() 
	-- Set Graphics context (local (x, y) relative to image)
	gfx.pushContext(self:getImage())
	
	-- Perform draw operations
	local sizeX, sizeY = self:getSize()
	
	-- Background fill
	gfx.setBackgroundColor(gfx.kColorBlack)
	gfx.fillRect(0, 0, sizeX, sizeY)
	
	-- Pattern fill
	gfx.setPattern(gfx.image.new("images/patterntable"), 20, 68)
	gfx.fillRect(0, 0, sizeX, sizeY)
	
	-- White Outline
	gfx.setColor(gfx.kColorWhite)
	gfx.setLineWidth(4)
	gfx.drawRect(0, 0, sizeX, sizeY)
	
	-- Close Graphics Context
	gfx.popContext()
end

function Platform:setSize(width, height)
	Platform.super.setSize(self, width, height)
	self:setImage(gfx.image.new(width, height))
	
	self:onSizeChanged()
end

function Platform:onSizeChanged()
	self:setCollideRect(0, 0, self:getSize())
	self:drawSelf()
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
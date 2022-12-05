import "engine"

class("WallOfDeath").extends(Sprite)

function WallOfDeath.new(speed) 
	return WallOfDeath(speed)
end

function WallOfDeath:init(speed)
	WallOfDeath.super.init(self, gfx.image.new(600, 240))
	self.type = spriteTypes.killBlock
	self.speed = speed
	----------------
	-- Set up Sprite
	
	self:setCollideRect(0, 0, self:getSize())
	self:setCenter(0, 0)
	
	-- Set Graphics context (local (x, y) relative to image)
	gfx.pushContext(self:getImage())
	
	-- Perform draw operations
	gfx.fillRect(0, 0, 300, 240)
	
	-- Close Graphics Context
	gfx.popContext()
end

function WallOfDeath:update()
	self:moveBy(self.speed, 0)
end

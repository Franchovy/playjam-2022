import "engine"

class('Platform').extends(gfx.sprite)

function Platform.new(image) 
	return Platform(image)
end

function Platform:init(image)
	Platform.super.init(self, image)
	self.type = "Platform"
	
	----------------
	-- Draw Graphics
	
	self:drawSelf()
	
	----------------
	-- Set up Sprite
	
	self:setCollideRect(0, 0, self:getSize())
	self:setCenter(0, 0)
end

function Platform:drawSelf() 
	-- Set Graphics context (local (x, y) relative to image)
	gfx.pushContext(self:getImage())
	
	-- Perform draw operations
	gfx.fillRect(0, 0, self:getSize())
	
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
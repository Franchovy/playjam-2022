import "engine"

class('Floor').extends(gfx.sprite)

function Floor.new(image) 
	return Floor(image)
end

function Floor:init(image)
	Floor.super.init(self, image)
	self.type = "Floor"
	
	----------------
	-- Draw Graphics
	
	self:drawSelf()
	
	----------------
	-- Set up Sprite
	
	self:setCollideRect(0, 0, self:getSize())
	self:setCenter(0, 0)
end

function Floor:drawSelf() 
	-- Set Graphics context (local (x, y) relative to image)
	gfx.pushContext(self:getImage())
	
	-- Perform draw operations
	gfx.fillRect(0, 0, self:getSize())
	
	-- Close Graphics Context
	gfx.popContext()
end

function Floor:setSize(width, height)
	Floor.super.setSize(self, width, height)
	self:setImage(gfx.image.new(width, height))
	
	self:onSizeChanged()
end

function Floor:onSizeChanged()
	self:setCollideRect(0, 0, self:getSize())
	self:drawSelf()
end
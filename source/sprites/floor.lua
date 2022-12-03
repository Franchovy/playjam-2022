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
	local image = self:getImage()
	
	-- Set Graphics context
	gfx.pushContext(image)
	
	-- Perform draw operations
	gfx.fillRect(0, 0, self:getSize())
	
	-- Close Graphics Context
	gfx.popContext()
	
	----------------
	-- Set up Sprite
	
	self:setCollideRect(0, 0, self:getSize())
	self:add()
end

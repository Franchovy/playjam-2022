import "engine"

class('Floor').extends(gfx.sprite)

function Floor.new() 
	return Floor()
end

function Floor:init()
	Floor.super.init(self, gfx.image.new(400, 20))
	self.type = "Floor"
	
	-- Draw Graphics
	
	-- Set Graphics context
	
	local image = self:getImage()
	gfx.pushContext(image)
	gfx.fillRect(0, 0, image:getSize())
	-- Close Graphics Context
	gfx.popContext()
	
	
	-- Set up Sprite
	self:setCollideRect(0, 0, self:getSize())
	self:moveTo(200, 230)
	self:add()
end
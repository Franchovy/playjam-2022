import "engine"

class('Floor').extends(gfx.sprite)

function Floor.new() 
	return Floor()
end

function Floor:init()
	Floor.super.init(self, gfx.image.new(400, 20))
	self.type = spriteType.floor
	
	-- Draw Graphics
	
	-- Set Graphics context
	local spriteImage = self:getImage()
	gfx.pushContext(spriteImage)
	-- Draw with Graphics Context
	gfx.fillRect(0, 0, spriteImage:getSize())
	-- Close Graphics Context
	gfx.popContext()
	
	-- Set up Sprite
	self:setCollideRect(0, 0, self:getSize())
	self:moveTo(200, 230)
	self:add()
end

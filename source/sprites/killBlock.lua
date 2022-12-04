import "engine"

class('KillBlock').extends(gfx.sprite)

function KillBlock.new(image) 
	return KillBlock(image)
end

function KillBlock:init(image)
	KillBlock.super.init(self, image)
	self.type = "KillBlock"
	
	----------------
	-- Draw Graphics
	
	self:drawSelf()
	
	----------------
	-- Set up Sprite
	
	self:setCollideRect(0, 0, self:getSize())
	self:setCenter(0, 0)
end

function KillBlock:drawSelf() 
	-- Set Graphics context (local (x, y) relative to image)
	gfx.pushContext(self:getImage())
	
	-- Perform draw operations
	gfx.fillRect(0, 0, self:getSize())
	
	-- Close Graphics Context
	gfx.popContext()
end

function KillBlock:setSize(width, height)
	KillBlock.super.setSize(self, width, height)
	self:setImage(gfx.image.new(width, height))
	
	self:onSizeChanged()
end

function KillBlock:onSizeChanged()
	self:setCollideRect(0, 0, self:getSize())
	self:drawSelf()
end
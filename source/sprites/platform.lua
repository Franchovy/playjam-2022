import "engine"

class('Platform').extends(Sprite)


function Platform.new(image,canMove) 
	return Platform(image,canMove)
end

function Platform:init(image,canMove)
	Platform.super.init(self, image)
	self.type = spriteTypes.platform
	self.canMove=canMove
	self.velocity=0
	self.currentOffset=0
	self.goLeft=true
	self.currentMove=0
	self.initPosX, self.initPosY=self:getPosition()
	--print("INITPOS:" .. self.initPosX)
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

function Platform:update()
	if(self.canMove) then
		
		print("ICANMOVE:")
		local x,y=self:getPosition()
		if(x~=0 and self.initPosX==0) then
			self.initPosX, self.initPosY=self:getPosition()
		end
		print("POSX:" .. tostring(x))
		print("currentMove:" .. tostring(self.currentMove))
		local minMoveX=-50
		local maxMoveX=50
		self.velocity=0.8
		if(self.currentMove>=maxMoveX) then
			self.goLeft=true
			self.currentMove=maxMoveX
		elseif (self.currentMove<=minMoveX) then
			self.goLeft=false
			self.currentMove=minMoveX
		end

		if(self.goLeft) then
			self.currentOffset=-1*self.velocity

		else
			self.currentOffset=1*self.velocity
		end

		self.currentMove+=self.currentOffset

		self:moveTo(self.initPosX+self.currentMove,y)

	

	end
	

end
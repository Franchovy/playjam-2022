
class("Painter").extends()

function Painter:init(drawFunction)
	self.drawFunction = drawFunction
	self.stateImages = {}
	self.offset = { x = 0, y = 0 }
end

function Painter:offsetBy(x, y)
	self.offset = { x = x, y = y }
	return self
end

function Painter:draw(state)
	if state ~= nil then
		self:_drawState(state)
	else 
		self:_draw()
	end
end

-- TODO: efficient implementation of table state checking
function Painter:_drawState(state)
	if self.stateImages[state] == nil then
		self.stateImages[state] = self:_drawImage(state)
	end
	
	self.stateImages[state]:draw(self.offset.x, self.offset.y)
end

function Painter:_draw()
	if self.image == nil then
		self.image = self:_drawImage()
	end
	
	self.image:draw(self.offset.x, self.offset.y)
end

function Painter:_drawImage(state)
	local image = playdate.graphics.image.new(playdate.display.getSize())
	playdate.graphics.pushContext(image)
	self.drawFunction(state)
	playdate.graphics.popContext()
	return image
end

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
	local _, image = self:_contains(self.stateImages, state)
	
	if image == nil then
		self.stateImages[state] = self:_drawImage(state)
		image = self.stateImages[state]
	end
	
	image:draw(self.offset.x, self.offset.y)
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

function Painter:_contains(set, t)
	for table, image in pairs(set) do
		if self:_shallowEqual(t, table) then
			return table, image
		end
	end
	
	return nil
end

function Painter:_shallowEqual(table1, table2)
	for k, v in pairs(table1) do
		if table2[k] == nil or table1[k] ~= table2[k] then
			return false
		end
	end
	
	return true
end
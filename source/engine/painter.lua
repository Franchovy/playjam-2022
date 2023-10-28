
class("Painter").extends()

function Painter:init(drawFunction)
	self.drawFunction = drawFunction
	self.stateImages = {}
	self.state = nil
end

function Painter:draw(rect, state)
	if state ~= nil then
		self:_drawState(rect, state)
	else 
		self:_draw(rect)
	end
end

-- TODO: efficient implementation of table state checking
function Painter:_drawState(rect, state)
	local stateExisting, image = self:_contains(self.stateImages, state)
	
	if image == nil then
		self.stateImages[state] = self:_drawImage(rect, state)
		image = self.stateImages[state]
	end
	
	image:draw(rect.x, rect.y)
end

function Painter:_draw(rect)
	if self.image == nil then
		self.image = self:_drawImage(rect)
	end
	
	self.image:draw(rect.x, rect.y)
end

function Painter:_drawImage(rect, state)
	local image = playdate.graphics.image.new(rect.w, rect.h)
	playdate.graphics.pushContext(image)
	self.drawFunction({x = 0, y = 0, w = rect.w, h = rect.h }, state)
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
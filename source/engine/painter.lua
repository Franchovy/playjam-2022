
class("Painter").extends()

function Painter:init(drawFunction)
	self.drawFunction = drawFunction
	self.stateImages = {}
	self.state = nil
end

function Painter:draw(rect, state)
	local image = self:_getImage(state)
	
	if image == nil then
		image = playdate.graphics.image.new(rect.w, rect.h)
		
		playdate.graphics.pushContext(image)
		self.drawFunction({x = 0, y = 0, w = rect.w, h = rect.h }, state)
		playdate.graphics.popContext()
		
		self:_setImage(image, state)
	end
	
	image:draw(rect.x, rect.y)
end

function Painter:_getImage(state)
	if state ~= nil then
		local _, image = self:_contains(self.stateImages, state)
		if image ~= nil then
			return image
		end
	elseif self.image ~= nil then
		return self.image
	end
	
	return nil
end

function Painter:_setImage(image, state)
	if state ~= nil then
		self.stateImages[state] = image
	else
		self.image = image
	end
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

function Painter:unload()
	self.stateImages = nil
	self.image = nil
	self.drawFunction = nil
end
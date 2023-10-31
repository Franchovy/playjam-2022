
class("Painter").extends()

function Painter:init(drawFunction)
	self.drawFunction = drawFunction
	self.stateImages = {}
	self.state = nil
	self.globals = {}
end

local globalImage = playdate.graphics.image.new(400, 240)

function Painter.clearGlobal() 
	globalImage:clear(playdate.graphics.kColorClear)
end

function Painter.drawGlobal() 
	globalImage:draw(0, 0)
end

function Painter:draw(rect, state, config)
	local absolute = self:_getConfig(config)
	local image = self:_getImage(state)
	
	if image == nil then
		image = playdate.graphics.image.new(rect.w, rect.h)
		
		playdate.graphics.pushContext(image)
		self.drawFunction({x = rect.x, y = rect.y, w = rect.w, h = rect.h }, state, self.globals)
		playdate.graphics.popContext()
		
		self:_setImage(image, state)
	end
	
	for _, global in pairs(self.globals) do
		if self:_shallowEqual(global.state, state) then
			global.fn()
		end
	end
	
	if absolute then
		playdate.graphics.lockFocus(globalImage)
		image:draw(rect.x, rect.y)
		playdate.graphics.unlockFocus()
	else
		image:draw(rect.x, rect.y)
	end
end

function Painter:_getConfig(config)
	local absolute = false
	
	if config ~= nil then
		if config.absolute ~= nil then
			absolute = config.absolute
		end
	end
	
	return absolute
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
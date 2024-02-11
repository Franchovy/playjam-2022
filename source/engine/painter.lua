import "extensions"

local gfx <const> = playdate.graphics

class("Painter").extends()

function Painter.factory(drawFunction)
	return function(...)
		local args = {...}
		return Painter(drawFunction, table.unpack(args))
	end
end

function Painter:init(drawFunction, ...)
	local args = {...}
	if #args > 0 then
		self.args = args
	end
	
	self.drawFunction = drawFunction
	
	self.stateImages = {}
	self.state = nil
end

function Painter:draw(frame, state)
	local image = self:_getImage(state)
	
	if image == nil then
		image = gfx.image.new(frame.w, frame.h)
		
		gfx.pushContext(image)
		self.drawFunction({x = 0, y = 0, w = frame.w, h = frame.h }, state, self.args ~= nil and table.unpack(self.args) or nil)
		gfx.popContext()
		
		self:_setImage(image, state)
	end
	
	image:draw(frame.x, frame.y)
	
	self.frame = frame
end

function Painter:markDirty( )
	if self.frame ~= nil then
		gfx.sprite.addDirtyRect(self.frame.x, self.frame.y, self.frame.w, self.frame.h)
	end
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
	for t2, image in pairs(set) do
		if table.shallowEqual(t, t2) then
			return t2, image
		end
	end
	
	return nil
end

function Painter:unload()
	self.stateImages = nil
	self.image = nil
	self.drawFunction = nil
end
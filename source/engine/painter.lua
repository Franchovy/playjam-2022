import "extensions"

class("Painter").extends()

function Painter:init(drawFunction)
	self.drawFunction = drawFunction
	
	self.stateImages = {}
	self.state = nil
end

function Painter:draw(frame, state)
	local image = self:_getImage(state)
	
	if image == nil then
		image = playdate.graphics.image.new(frame.w, frame.h)
		
		playdate.graphics.pushContext(image)
		self.drawFunction({x = 0, y = 0, w = frame.w, h = frame.h }, state)
		playdate.graphics.popContext()
		
		self:_setImage(image, state)
	end
	
	image:draw(frame.x, frame.y)
	
	self.frame = frame
end

function Painter:markDirty( )
	if self.frame ~= nil then
		playdate.graphics.sprite.addDirtyRect(self.frame.x, self.frame.y, self.frame.w, self.frame.h)
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
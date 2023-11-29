class("Widget").extends()

Widget.drawList = {}

Widget.kDeps = {
	children = 1,
	state = 2,
	samples = 3
}

function Widget:createSprite(zIndex)
	if self.sprite == nil then
		local sprite = gfx.sprite.new()
		sprite:setSize(playdate.display.getSize())
		sprite:setCenter(0, 0)
		sprite:moveTo(0, 0)
		
		if zIndex ~= nil then
			sprite:setZIndex(zIndex)
		else
			sprite:setZIndex(-32768)
		end
		
		sprite:setIgnoresDrawOffset(true)
		sprite:setUpdatesEnabled(false)
		sprite.setAlwaysRedraw(true)
		sprite.draw = function(s, x, y, w, h)
			self:draw(Rect.make(x, y, w, h), self.state)
		end
		
		sprite:add()
		self.sprite = sprite
	end
end

function Widget.new(class, ...)
	local widget = class(...)
	
	widget._state = {
		isLoaded = false,
		isVisible = true
	}
	
	return widget
end

function Widget.supply(widget, dep)
	if dep == Widget.kDeps.children then
		widget:_supplyDepChildren()
	elseif dep == Widget.kDeps.state then
		widget:_supplyDepState()
	elseif dep == Widget.kDeps.samples then
		widget:_supplyDepSamples()
	end
end

function Widget._supplyDepChildren(self)
	self.children = {}
end

function Widget._supplyDepState(self)
	function self:setStateInitial(states, state)
		self.kStates = states
		self.state = state
	end
	function self:setState(targetState)
		if self.changeState ~= nil then
			self:changeState(self.state, targetState)
		end
		
		self.state = targetState
	end
end

function Widget._supplyDepSamples(self)
	self.samples = {}
	function self:loadSample(path, key, volume)
		if key == nil then
			key = path
		end
		self.samples[path] = playdate.sound.sampleplayer.new(path)
		
		if volume ~= nil then
			self.samples[path]:setVolume(volume)
		end
	end
	function self:playSample(key, ...)
		self.samples[key]:play(...)
	end
end

function Widget.load(self)
	self:_load()
	
	self._state.isLoaded = true
end

function Widget.setVisible(self, isVisible)
	self._state.isVisible = isVisible
end

function Widget.isVisible(self)
	return self._state.isVisible
end

function Widget.unload(self)
	self._state.isLoaded = false
end

function Widget:isLoaded()
	return self._state.isLoaded	
end

function Widget:update()
	if self._state.isLoaded == false or (self._state.isVisible == false) then
		return
	end
	
	self:_update()
	
	if self.children ~= nil then
		for _, child in pairs(self.children) do
			child:update()
		end
	end
end

function Widget:draw(rect)
	if self._state.isLoaded == false or (self._state.isVisible == false) then
		return
	end

	self:_draw(rect)
end

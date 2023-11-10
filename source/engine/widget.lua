class("Widget").extends()

Widget.topLevelWidget = nil

Widget.kDeps = {
	children = 1,
	state = 2,
	samples = 3
}

function Widget.main(topLevelWidgetClass, ...)
	Widget.setBackgroundDrawingCallback()
	
	Widget.topLevelWidget = Widget.new(topLevelWidgetClass, ...)
end

function Widget.new(class, ...)
	local widget = class(...)
	
	widget._state = {
		isLoaded = false,
		isDrawable = false,
		isHidden = false
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
	function self:loadSample(path, key)
		if key == nil then
			key = path
		end
		self.samples[path] = playdate.sound.sampleplayer.new(path)
	end
	function self:playSample(key, ...)
		self.samples[key]:play(...)
	end
end

function Widget.setBackgroundDrawingCallback()
	playdate.graphics.sprite.setBackgroundDrawingCallback(
		function( x, y, width, height )
			Widget.draw()
		end
	)
end

function Widget.load(self)
	self:_load()
	
	self._state.isLoaded = true
end

function Widget.setIsHidden(self, isHidden)
	if isHidden == nil then
		isHidden = false
	end
		
	self._state.isHidden = isHidden
end

function Widget.isHidden(self)
	return self._state.isHidden
end

function Widget.unload(self)
	self._state.isLoaded = false
end

function Widget:isLoaded()
	return self._state.isLoaded	
end

function Widget.update(self)
	if self == nil then
		if Widget.topLevelWidget == nil then
			return
		end
		
		Widget.topLevelWidget:update()
	else
		if self._state.isLoaded == false or (self._state.isHidden == true) then
			return
		end
		
		self:_update()
		
		if self.children ~= nil then
			for _, child in pairs(self.children) do
				child:update()
			end
		end
	end
end

function Widget.draw(self, rect)
	if self == nil then
		if Widget.topLevelWidget == nil then
			return
		end
		
		-- Draw Hierarchy
		local rect = playdate.display.getRect()
		Widget.topLevelWidget:draw(Rect.make(rect.x, rect.y, rect.width, rect.height))
	else
		if self._state.isLoaded == false or (self._state.isHidden == true) then
			return
		end

		self:_draw(rect)
	end
end

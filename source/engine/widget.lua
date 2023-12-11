class("Widget").extends()

Widget.drawList = {}

Widget.kDeps = {
	children = 1,
	state = 2,
	samples = 3,
	animators = 4,
	update = 5
}

function Widget:createSprite(zIndex)
	if self.sprite == nil then
		local sprite = playdate.graphics.sprite.new()
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
		sprite.draw = function(s, x, y, w, h)
			local frame = Rect.make(s.x, s.y, s.width, s.height)
			local drawRect = Rect.make(x, y, w, h)
			self:draw(frame, self.state, drawRect)
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
	elseif dep == Widget.kDeps.animators then
		widget:_supplyDepAnimators()
	elseif dep == Widget.kDeps.update then
		widget:_supplyDepUpdate()
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

function Widget._supplyDepUpdate(self)
	self._updateCallbacks = {}
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
	function self:unloadSample(key)
		self.samples[key] = nil
	end
end

function Widget._supplyDepAnimators(self)
	self.animators = {}
	
	function self:setAnimations(animations) 
		self.kAnimations = animations
	end
	function self:animatorsEnded()
		for _, animator in pairs(self.animators) do
			if animator.didend ~= true then
				return false
			end
		end
		
		return true
	end
	function self:animate(animation, finishedCallback)
		local previousAnimation = {
			animation = animation,
			timestamp = playdate.getCurrentTimeMilliseconds()
		}
		
		self._previousAnimation = previousAnimation
		
		function queueFinishedCallback(delay)
			if finishedCallback ~= nil then
				playdate.timer.performAfterDelay(delay, function() 
					local animationChanged = (previousAnimation.animation ~= self._previousAnimation.animation) 
						or (previousAnimation.timestamp ~= self._previousAnimation.timestamp)
					
					finishedCallback(animationChanged)
					
					if animationChanged == false then
						self._previousAnimation.isended = true
					end
				end)
			end
		end
		
		self:_animate(animation, queueFinishedCallback)
	end
	function self:isAnimating()
		if self._previousAnimation == nil then
			return false
		elseif self._previousAnimation.isended == nil then
			return false
		else
			return self._previousAnimation.isended
		end
	end
	table.insert(self._updateCallbacks, function()
		for _, animator in pairs(self.animators) do
			animator:update()
		end
	end)
end

function Widget.load(self)
	self:_load()
	
	self._state.isLoaded = true
end

function Widget.setVisible(self, isVisible)
	self._state.isVisible = isVisible
	
	if self.children ~= nil then
		for _, child in pairs(self.children) do
			child:setVisible(isVisible)
		end
	end	
end

function Widget.isVisible(self)
	return self._state.isVisible
end

function Widget.unload(self)
	if self._state.isLoaded == false then
		return
	end
	
	self._state.isLoaded = false
	
	if self._unload ~= nil then
		self:_unload()
	end
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
	
	if self._updateCallbacks ~= nil then
		for _, callback in pairs(self._updateCallbacks) do
			callback()
		end
	end
end

function Widget:draw(frame, rect)
	if self._state.isLoaded == false or (self._state.isVisible == false) then
		return
	end

	self:_draw(frame, rect)
end

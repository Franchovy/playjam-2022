local geo <const> = playdate.geometry
function animators(widget)
	
	function widget:getAnimatorValue(...)
		local animators = {...}
		local type
		local value
		for _, animator in pairs(animators) do
			if value == nil then
				if getmetatable(animator:currentValue()) == nil then
					value = 0
					type = "number"
				elseif getmetatable(animator:currentValue()).__name == "playdate.geometry.point" then
					value = geo.point.new(0, 0)
					type = "playdate.geometry.point"
				end
			end
			
			if type == "number" then
				value += animator:currentValue()
			elseif type == "playdate.geometry.point" then
				assert(getmetatable(animator:currentValue()).__name == "playdate.geometry.point", "Error: Attempted to add animators with different value types.")
				value:offset(animator:currentValue().x, animator:currentValue().y)
			end
		end
		
		if value ~= nil then
			return value
		else
			return 0
		end
	end
	
	function widget:animatorsEnded()
		for _, animator in pairs(self.animators) do
			if animator.didend ~= true then
				return false
			end
		end
		
		return true
	end
	
	function widget:wasAnimating()
		return self._state.wasAnimating == true
	end
	
	function widget:isAnimating()
		return self._state.isAnimating == true
	end
	
	widget:_addUpdateCallback(function(self)
		local state = self._state
		state.wasAnimating = self._state.isAnimating ~= nil and self._state.isAnimating or false
		state.isAnimating = false
		
		local state = self._state
		for _, animator in pairs(self.animators) do
			animator:update()
			
			state.isAnimating = state.isAnimating or animator:isAnimating()
		end
	end)
	
	widget.animators = {}
end

Widget.register("animators", animators)
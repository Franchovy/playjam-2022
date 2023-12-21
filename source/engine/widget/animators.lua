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
					value = playdate.geometry.point.new(0, 0)
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
	
	function widget:isAnimating()
		for _, animator in pairs(self.animators) do
			if (animator.previousUpdateTime == nil) or (animator.didend ~= true) then
				return true
			end
		end
			
		return false
	end
	
	widget:_addUpdateCallback(function()
		for _, animator in pairs(widget.animators) do
			animator:update()
		end
	end)
	
	widget.animators = {}
end

Widget.register("animators", animators)
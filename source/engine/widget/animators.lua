local geo <const> = playdate.geometry

local _type <const> = type
local _assert <const> = assert

function animators(widget)
	
	function widget:getAnimatorValue(...)
		local _animators = {...}
		local _isNumberList
		local _value
		for _, animator in pairs(_animators) do
			local _currentValue = animator:currentValue()
			local _isNumber = _type(_currentValue) == "number"
			if _isNumberList == nil then
				_isNumberList = _isNumber
				
				if _isNumber then
					_value = 0
				else
					_value = geo.point.new(0, 0)
				end
			else
				_assert(_isNumber == _isNumberList)
			end
			
			if _isNumber then
				_value += _currentValue
			else
				_value:offset(_currentValue.x, _currentValue.y)
			end
		end
		
		if _value ~= nil then
			return _value
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
		local _state = self._state
		_state.wasAnimating = _state.isAnimating ~= nil and _state.isAnimating or false
		_state.isAnimating = false
		
		for _, animator in pairs(self.animators) do
			animator:update()
			
			_state.isAnimating = _state.isAnimating or animator:isAnimating()
		end
	end)
	
	widget.animators = {}
end

Widget.register("animators", animators)
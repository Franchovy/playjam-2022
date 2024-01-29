local emptyInput = { pressed = 0, released = 0, current = 0 }

local function clear(input)
	input.current = 0
	input.pressed = 0
	input.released = 0
end

local function input(widget)
	widget._filter = playdate.kButtonsAny
	widget._input = table.shallowcopy(emptyInput)
	local _input = widget._input
	
	function widget:registerDeviceInput()
		_input.current, _input.pressed, _input.released = playdate.getButtonState()
	end
	
	function widget:passInput(child, filter)
		if filter == nil then
			filter = playdate.kButtonsAny
		end
		
		local input = child._input
		
		input.pressed = _input.pressed & filter
		input.current = _input.current & filter
		input.released = _input.released & filter
		
		self:filterInput(playdate.kButtonsAny ~ filter)
	end
	
	function widget:filterInput(filter)
		self._filter = filter
	end
	
	widget:_addUpdateCallback(function(self)
		if ((_input.pressed | _input.released | _input.current) & self._filter) ~= 0 then
			if self._handleInput ~= nil then
				self:_handleInput(_input)
			end
		end
		
		clear(_input)
		self._filter = playdate.kButtonsAny
	end)
end

Widget.register("input", input)
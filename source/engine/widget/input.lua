local emptyInput = { pressed = 0, released = 0, current = 0 }

local function input(widget)
	function widget:registerDeviceInput()
		local current, pressed, released = playdate.getButtonState()
		self._input = { current = current, pressed = pressed, released = released }
	end
	
	function widget:passInput(child, filter)
		if filter == nil then
			filter = playdate.kButtonsAny
		end
		
		local input = table.shallowcopy(self._input)
		
		if filter ~= nil then
			input.pressed = input.pressed & filter
			input.current = input.current & filter
			input.released = input.released & filter
		end
		
		child._input = input
		
		self:filterInput(playdate.kButtonsAny ~ filter)
	end
	
	function widget:filterInput(filter)
		self._filter = filter
	end
	
	widget:_addUpdateCallback(function()
		local input = widget._input
		
		if ((input.pressed | input.released | input.current) & widget._filter) ~= 0 then
			if widget._handleInput ~= nil then
				widget:_handleInput(input)
			end
		end
		
		widget._input = emptyInput
		widget._filter = playdate.kButtonsAny
	end)
	
	widget._input = emptyInput
	widget._filter = playdate.kButtonsAny
end

Widget.register("input", input)
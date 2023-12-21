local emptyInput = { pressed = 0, released = 0, current = 0 }

local function input(widget)
	function widget:registerDeviceInput()
		local current, pressed, released = playdate.getButtonState()
		self._input = { current = current, pressed = pressed, released = released }
	end
	
	function widget:passInput(child, input)
		child._input = input or self._input
	end
	
	function widget:handleInput()
		if self._handleInput ~= nil then
			self:_handleInput(self._input)
		end
	end
	
	widget:_addUpdateCallback(function()
		widget._input = emptyInput
	end)
	
	widget._input = emptyInput
end

Widget.register("input", input)
local function state(widget)
	local _state
	
	function widget:setStateInitial(states, state)
		self.kStates = states
		_state = state
		self.state = state
	end
	
	function widget:setState(targetState)
		if self.state == targetState then
			return
		end
		
		_state = targetState
	end
	
	widget:_addUpdateCallback(function()
		if widget.state ~= _state then
			if widget._changeState ~= nil then
				widget:_changeState(widget.state, _state)
			end
			
			widget.state = _state
		end
	end)
end

Widget.register("state", state)
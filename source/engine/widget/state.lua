local function state(widget)
	local _state
	local _kStatesIndexed
	
	function widget:setStateInitial(state, states)
		local _kStatesKeyed
		
		if type(states) == "number" then
			_kStatesIndexed = table.create(number, 0)
			for i=1, states do
				table.insert(_kStatesIndexed, i)
			end
			_kStatesKeyed = _kStatesIndexed
		elseif type(states) == "table" then
			_kStatesIndexed = table.create(#states, 0)
			_kStatesKeyed = table.create(0, #states)
			for i, state in ipairs(states) do
				table.insert(_kStatesIndexed, state)
				_kStatesKeyed[state] = i
			end
		end
		
		self.kStates = _kStatesKeyed
		
		_state = state
		self.state = state
	end
	
	function widget:setState(targetState)
		assert(_state == self.state, "State has been set twice within this frame, and hasn't had time to update. Ensure there is some delay between setState() calls to update!")
		assert(_kStatesIndexed == nil or _kStatesIndexed[targetState] ~= nil, "Target state is not part of this widget's states!")
		
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
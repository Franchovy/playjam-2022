
function keyValueState(widget)
	
	function widget:setStateInitial(stateTable, state)
		self.state = state
		self.kStates = stateTable
		
		self.kStateKeys = {}
		for k, _ in pairs(stateTable) do
			self.kStateKeys[k] = k
		end
	end
	
	function widget:setState(key, value)
		if self.state[key] == value then
			return
		end
		
		local updatedState = table.shallowcopy(self.state)
		updatedState[key] = value
		
		if self._changeState ~= nil then
			self:_changeState(self.state, updatedState)
		end
		
		self.state = updatedState
	end
end

Widget.register("keyValueState", keyValueState)
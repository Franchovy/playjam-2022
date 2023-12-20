
Settings = {}
Settings._data = {}
Settings._callbackFunctions = {}

function Settings:getValue(key)
	return self._data[key]
end

function Settings:setValue(key, value)
	self._data[key] = value
	
	if self._callbackFunctions[key] ~= nil then
		self._callbackFunctions[key](value)
	end
end

function Settings:setCallback(key, callbackFunction)
	self._callbackFunctions[key] = callbackFunction
end

-- function Settings:writeToDisk
-- function Settings:readFromDisk
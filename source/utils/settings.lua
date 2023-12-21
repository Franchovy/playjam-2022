
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

function Settings:existsSettingsFile()
	return playdate.file.exists(kFilePath.settings)
end

function Settings:readFromFile()
	local data = json.decodeFile(kFilePath.settings)
	
	for k, v in pairs(data) do
		self:setValue(k, v)
	end
end

function Settings:writeToFile()
	json.encodeToFile(kFilePath.settings, true, self._data)
end

function Settings:setDefaultValues(data)
	for k, v in pairs(data) do
		self:setValue(k, v)
	end
	
	self:writeToFile()
end
	
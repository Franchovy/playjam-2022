function loadLevelFromFile(filepath)
	local config = json.decodeFile(filepath)
	
	for _, object in pairs(config.objects) do
		if object.config ~= nil then
			local configArray = {}
			configArray[0] = object.config
			object.config = configArray
		end
	end
	
	return config
end
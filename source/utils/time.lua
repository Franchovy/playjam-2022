
function convertToTimeString(timeValueMs, decimalsCount)
	local timeInSeconds = timeValueMs / 1000
	
	if timeInSeconds < 60 then
		local seconds = math.floor(timeInSeconds) % 60
		
		if decimalsCount == 2 then
			local decimal = math.floor(timeValueMs / 10) % 100
			return string.format("%02d.%02d", seconds, decimal)
		elseif decimalsCount == 1 then
			local decimal = math.floor(timeValueMs / 100) % 10
			return string.format("%02d.%01d", seconds, decimal)
		end
	else
		local seconds = math.floor(timeInSeconds) % 60
		local minutes = math.floor(timeInSeconds / 60)
		
		return string.format("%02d:%02d", minutes, seconds)
	end
end
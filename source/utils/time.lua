
function convertToTimeString(timeValueMs, decimalsCount)
	if decimalsCount == nil then
		decimalsCount = 2
	end
	
	local decimal = math.floor(timeValueMs / 10)
	local seconds = math.floor(decimal / 100)
	
	if decimal < 10 then
		decimal = "0"..decimal
	end
	
	if seconds < 59 then
		
		return string.sub(seconds, -2, -1).."."..string.sub(decimal, -decimalsCount, -1)
	else 
		local minutes = math.floor(seconds / 60)
		
		return minutes..":"..seconds.."."..decimal
	end
end
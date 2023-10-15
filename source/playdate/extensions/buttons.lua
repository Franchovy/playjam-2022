function playdate.getAllButtons()
	return {
		playdate.kButtonLeft,
		playdate.kButtonRight,
		playdate.kButtonDown,
		playdate.kButtonUp,
		playdate.kButtonA,
		playdate.kButtonB
	}
end

function playdate._methodButtonAny(method, ...)
	local arg = {...}
		
	if #arg == 0 then
		arg = playdate.getAllButtons()
	end
	
	for _, button in ipairs(arg) do
		if method(button) then
			return true
		end
	end
	
	return false
end

function playdate.buttonIsPressedAny(...)
	return playdate._methodButtonAny(playdate.buttonIsPressed, ...)
end

function playdate.buttonJustPressedAny(...)
	return playdate._methodButtonAny(playdate.buttonJustPressed, ...)
end

function playdate.buttonJustReleasedAny(...)
	return playdate._methodButtonAny(playdate.buttonJustReleased, ...)
end
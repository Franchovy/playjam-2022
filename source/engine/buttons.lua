
playdate.buttons = {
	left = playdate.kButtonLeft,
	right = playdate.kButtonRight,
	down = playdate.kButtonDown,
	up = playdate.kButtonUp,
	a = playdate.kButtonA,
	b = playdate.kButtonB
}

buttons = table.shallowcopy(playdate.buttons)

-- TODO: Deprecate - Use original playdate functions
function buttons.isLeftButtonPressed() return playdate.buttonIsPressed(playdate.kButtonLeft) end
function buttons.isRightButtonPressed() return playdate.buttonIsPressed(playdate.kButtonRight) end
function buttons.isDownButtonPressed() return playdate.buttonIsPressed(playdate.kButtonDown) end
function buttons.isUpButtonPressed() return playdate.buttonIsPressed(playdate.kButtonUp) end
function buttons.isAButtonPressed() return playdate.buttonIsPressed(playdate.kButtonA) end
function buttons.isBButtonPressed() return playdate.buttonIsPressed(playdate.kButtonB) end
function buttons.isLeftButtonJustPressed() return playdate.buttonJustPressed(playdate.kButtonLeft) end
function buttons.isRightButtonJustPressed() return playdate.buttonJustPressed(playdate.kButtonRight) end
function buttons.isDownButtonJustPressed() return playdate.buttonJustPressed(playdate.kButtonDown) end
function buttons.isUpButtonJustPressed() return playdate.buttonJustPressed(playdate.kButtonUp) end
function buttons.isAButtonJustPressed() return playdate.buttonJustPressed(playdate.kButtonA) end
function buttons.isBButtonJustPressed() return playdate.buttonJustPressed(playdate.kButtonB) end
function buttons.isLeftButtonJustReleased() return playdate.buttonJustReleased(playdate.kButtonLeft) end
function buttons.isRightButtonJustReleased() return playdate.buttonJustReleased(playdate.kButtonRight) end
function buttons.isDownButtonJustReleased() return playdate.buttonJustReleased(playdate.kButtonDown) end
function buttons.isUpButtonJustReleased() return playdate.buttonJustReleased(playdate.kButtonUp) end
function buttons.isAButtonJustReleased() return playdate.buttonJustReleased(playdate.kButtonA) end
function buttons.isBButtonJustReleased() return playdate.buttonJustReleased(playdate.kButtonB) end

-- 

function buttons.isButtonPressed(button) return playdate.buttonPressed(button) end
function buttons.isButtonJustPressed(button) return playdate.buttonJustPressed(button) end
function buttons.isButtonJustReleased(button) return playdate.buttonJustReleased(button) end

--

function buttons.getAllButtons()
	return {
		playdate.kButtonLeft,
		playdate.kButtonRight,
		playdate.kButtonDown,
		playdate.kButtonUp,
		playdate.kButtonA,
		playdate.kButtonB
	}
end

function buttons.isButtonPressedAny(...)
	local arg = {...}
		
	if #arg == 0 then
		return buttons.isButtonPressedAny(buttons.getAllButtons())
	end
	
	for _, button in ipairs(arg) do
		if buttons.isButtonPressed(button) then
			return true
		end
	end
	
	return false
end

local cntOut = 0

function buttons.isButtonJustPressedAny(...)
	local arg = {...}
	
	cntOut += 1
	
	if #arg == 0 then
		if cntOut > 5 then
			return false
		end
		return buttons.isButtonJustPressedAny(buttons.getAllButtons())
	end
	
	for _, button in ipairs(arg) do
		if buttons.isButtonJustPressed(button) then
			return true
		end
	end
	
	return false
end

function buttons.isButtonJustReleasedAny(...)
	local arg = {...}
		
	if #arg == 0 then
		return buttons.isButtonJustReleasedAny(buttons.getAllButtons())
	end
	
	for _, button in ipairs(arg) do
		if buttons.isButtonJustReleased(button) then
			return true
		end
	end
	
	return false
end
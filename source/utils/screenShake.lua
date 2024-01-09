local disp <const> = playdate.display
local timer <const> = playdate.timer

function screenShake(shakeTime, shakeMagnitude)
	local timer = timer.new(shakeTime, shakeMagnitude, 0)

	timer.updateCallback = function(timer)
		local magnitude = math.floor(timer.value)
		local shakeX = math.random(-magnitude, magnitude)
		local shakeY = math.random(-magnitude, magnitude)
		disp.setOffset(shakeX, shakeY)
	end
	
	timer.timerEndedCallback = function()
		disp.setOffset(0, 0)
	end
end
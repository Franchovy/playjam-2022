
function screenShake(shakeTime, shakeMagnitude)
	local timer = playdate.timer.new(shakeTime, shakeMagnitude, 0)

	timer.updateCallback = function(timer)
		local magnitude = math.floor(timer.value)
		local shakeX = math.random(-magnitude, magnitude)
		local shakeY = math.random(-magnitude, magnitude)
		playdate.display.setOffset(shakeX, shakeY)
	end
	
	timer.timerEndedCallback = function()
		playdate.display.setOffset(0, 0)
	end
end
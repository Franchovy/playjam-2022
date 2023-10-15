
-- Creates a blinker and a timer that restarts the blinker periodically. Returns blinker, timer, and a destroy method that can be called to remove both.
function periodicBlinker(blinkerConfig, delay)
	-- blinker "loop" parameter cannot be false.
	assert(blinkerConfig.loop ~= true)
	
	local blinker = playdate.graphics.animation.blinker.new(
		blinkerConfig.onDuration,
		blinkerConfig.offDuration,
		blinkerConfig.loop,
		blinkerConfig.cycles,
		blinkerConfig.default
	)
	
	local blinkerDuration = (blinker.onDuration + blinker.offDuration) * blinker.cycles / 2
	local timerDelay = blinkerDuration + delay
	
	local timer = playdate.timer.new(timerDelay)
	timer.repeats = true
	timer.timerEndedArgs = {blinker, timer}
	timer.timerEndedCallback = function(blinker, timer) 
		timer:reset()
		timer:start()
		blinker:start()
	end
	
	blinker:start()
	timer:start()
	
	local destroyMethod = function()
		timer:remove()
		timer = nil
		blinker:remove()
		blinker = nil
	end
	
	return timer, blinker, destroyMethod
end
local timer <const> = playdate.timer
local gfx <const> = playdate.graphics

-- Creates a blinker and a timer that restarts the blinker periodically. Returns blinker, timer, and a destroy method that can be called to remove both.
function periodicBlinker(blinkerConfig, delay)
	-- blinker "loop" parameter cannot be false.
	assert(blinkerConfig.loop ~= true)
	
	local blinker = gfx.animation.blinker.new(
		blinkerConfig.onDuration,
		blinkerConfig.offDuration,
		blinkerConfig.loop,
		blinkerConfig.cycles,
		blinkerConfig.default
	)
	
	local blinkerDuration = (
		blinker.onDuration + blinker.offDuration) * blinker.cycles / 2
	local timerDelay = blinkerDuration + delay
	
	local timer = timer.new(timerDelay)
	timer.repeats = true
	timer.discardOnCompletion = false
	
	timer.timerEndedArgs = {blinker, timer}
	timer.timerEndedCallback = function(blinker, timer) 
		blinker:start()
		timer:reset()
		timer:start()
	end
	
	-- Timers start when initialized, so we pause and reset.

	timer:pause()
	blinker:stop()
	
	-- Build periodicBlinker
	
	local periodicBlinker = {
		timer = timer,
		blinker = blinker,
		hasChanged = false,
		previousValue = blinker.on
	}
	
	function periodicBlinker.start(self)
		self.blinker:start()
		self.timer:start()
	end
	
	function periodicBlinker.update(self)
		if self.blinker == nil or self.timer == nil then
			return
		end
		if self.previousValue ~= self.blinker.on then
			self.hasChanged = true
		else 
			self.hasChanged = false
		end
		
		self.previousValue = self.blinker.on
	end
	
	function periodicBlinker.stop(self)
		self.timer:reset()
		self.timer:pause()
		self.blinker:stop()
	end
	
	function periodicBlinker.destroy(self)
		self.timer:remove()
		self.timer = nil
		self.blinker:remove()
		self.blinker = nil
	end
	
	return periodicBlinker
end
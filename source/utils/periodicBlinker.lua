
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
	
	local blinkerDuration = (
		blinker.onDuration + blinker.offDuration) * blinker.cycles / 2
	local timerDelay = blinkerDuration + delay
	
	local timer = playdate.timer.new(timerDelay)
	timer.repeats = true
	timer.timerEndedArgs = {blinker}
	
	timer.timerEndedCallback = function(blinker) 
		blinker:start()
		
		print("Callback!")
	end
	
	-- Timers start when initialized, so we pause and reset.
	timer:pause()
	timer:reset()
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
		
		print("Start")	
	end
	
	function periodicBlinker.update(self)
		if self.previousValue ~= self.blinker.on then
			self.hasChanged = true
		else 
			self.hasChanged = false
		end
		
		self.previousValue = self.blinker.on
		
		print("update: ".. (self.hasChanged and "true" or "false"))
	end
	
	function periodicBlinker.pause(self)
		self.timer:pause()
		self.timer:reset()
		self.blinker:stop()
		
		print("Pause")
	end
	
	function periodicBlinker.destroy(self)
		self.timer:remove()
		self.timer = nil
		self.blinker:remove()
		self.blinker = nil
		
		print("Destroy")
	end
	
	return periodicBlinker
end
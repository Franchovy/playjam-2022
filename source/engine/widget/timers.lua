function timers(widget)
	widget.timers = {}
	
	function widget:performAfterDelay(delay, callback, ...)
		local timer = playdate.timer.performAfterDelay(delay, callback, ...)
		table.insert(self.timers, timer)
	end
	
	widget:_addUnloadCallback(function()
		for _, timer in pairs(widget.timers) do
			timer:remove()
		end
	end)
end

Widget.register("timers", timers)
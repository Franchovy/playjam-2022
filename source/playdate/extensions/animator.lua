function playdate.graphics.animator:update()
	if self.duration == 0 then
		-- Ignore placeholder animators
		return
	end
	
	if self.previousUpdateTime ~= nil and (self.previousUpdateTime < playdate.getCurrentTimeMilliseconds()) then
		if self.updateCallback ~= nil then
			self.updateCallback()
		end
	end
	
	self.previousUpdateTime = playdate.getCurrentTimeMilliseconds()
	
	if self:ended() and (self.hasCalledFinishedCallback ~= true) then
		if self.finishedCallback ~= nil then
			self.finishedCallback()
		end
		
		self.hasCalledFinishedCallback = true
	end
end
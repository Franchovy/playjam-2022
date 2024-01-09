function playdate.graphics.animator:update()
	if self.hasCalledFinishedCallback == true or (self.duration == 0) then
		-- Ignore placeholder animators
		return
	end
	
	local currentTime = playdate.getCurrentTimeMilliseconds()
	if self.previousUpdateTime ~= nil and (self.previousUpdateTime < currentTime) then
		if self.updateCallback ~= nil then
			self.updateCallback()
		end
	end
	
	self.previousUpdateTime = currentTime
	
	if self:ended() and (self.hasCalledFinishedCallback ~= true) then
		if self.finishedCallback ~= nil then
			self.finishedCallback()
		end
		
		self.hasCalledFinishedCallback = true
	end
end

function playdate.graphics.animator:isAnimating()
	return (self.previousUpdateTime == nil) or (self.didend ~= true)
end
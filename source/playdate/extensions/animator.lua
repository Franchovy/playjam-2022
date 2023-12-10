function playdate.graphics.animator:update()
	if self.previousUpdateTime ~= nil and (self.previousUpdateTime < playdate.getCurrentTimeMilliseconds()) then
		if self.updateCallback ~= nil then
			self.updateCallback()
		end
	end
	
	self.previousUpdateTime = playdate.getCurrentTimeMilliseconds()
	
	if self:ended() and (self.hasCalledFinishedCallback == false) then
		if self.finishedCallback ~= nil then
			self.finishedCallback()
		end
		
		self.hasCalledFinishedCallback = true
	end
end
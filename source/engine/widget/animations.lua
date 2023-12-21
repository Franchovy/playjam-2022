function animations(widget)
	function widget:setAnimations(animations) 
		self.kAnimations = animations
	end
	function widget:animate(animation, finishedCallback)
		local previousAnimation = {
			animation = animation,
			timestamp = playdate.getCurrentTimeMilliseconds()
		}
		
		self._previousAnimation = previousAnimation
		
		function queueFinishedCallback(delay)
			if delay ~= nil then
				playdate.timer.performAfterDelay(delay, function() 
					local animationChanged = (previousAnimation.animation ~= self._previousAnimation.animation) 
						or (previousAnimation.timestamp ~= self._previousAnimation.timestamp)
					
					if finishedCallback ~= nil then
						finishedCallback(animationChanged)
					end
					
					if animationChanged == false then
						self._previousAnimation.isended = true
					end
				end)
			end
		end
		
		self:_animate(animation, queueFinishedCallback)
	end
end

Widget.register("animations", animations, {
	dependsOn = { "animators" }
})
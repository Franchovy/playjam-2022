class("WidgetStar").extends(Widget)

function WidgetStar:init(config)
	local initialDelay = config.initialDelay
	
	self.imagetables = {}
	self.timers = {}
	
	self.tick = 1
	
	local tickValues = {
		initialDelay, 90, 90, 120, 360
	}
	local tickValuesSum = {}
	local sum = 0
	for _, v in pairs(tickValues) do
		sum += v
		table.insert(tickValuesSum, sum)
	end
	
	self.timerDuration = sum
	self.tickFunction = function(timer)
		if self.tick > #tickValuesSum then 
			timer:remove()
		elseif timer.currentTime >= tickValuesSum[self.tick] then
			self.tick += 1
		end
	end
end

function WidgetStar:_load()
	self.imagetables.star = playdate.graphics.imagetable.new(kAssetsImages.star)
	
	self.timers.timer = playdate.timer.new(self.timerDuration)
	self.timers.timer:pause()
	
	function self:isAnimating()
		return self.timers.timer ~= nil and (self.timers.timer.paused == false) and (self.timers.timer.timeLeft > 0)
	end
end

function WidgetStar:_draw(rect)
	self.imagetables.star:getImage(self.tick):draw(rect.x, rect.y)
end

function WidgetStar:_update()
	if not self.timers.timer.paused then
		self.tickFunction(self.timers.timer)
	end
end
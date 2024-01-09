local gfx <const> = playdate.graphics
local timer <const> = playdate.timer
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
	self.imagetables.star = gfx.imagetable.new(kAssetsImages.star)
	
	self.timers.timer = timer.new(self.timerDuration)
	self.timers.timer:pause()
	
	function self:isAnimating()
		return self._state.isAnimating
	end
	function self:wasAnimating()
		return self._state.wasAnimating
	end
end

function WidgetStar:_draw(rect)
	self.imagetables.star:getImage(self.tick):draw(rect.x, rect.y)
end

function WidgetStar:_update()
	if not self.timers.timer.paused then
		self.tickFunction(self.timers.timer)
	end
	
	self._state.wasAnimating = self._state.isAnimating ~= nil and self._state.isAnimating or false
	self._state.isAnimating = self.timers.timer ~= nil and (self.timers.timer.paused == false) and (self.timers.timer.timeLeft > 0)
end
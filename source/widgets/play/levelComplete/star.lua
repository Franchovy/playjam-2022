class("WidgetStar").extends(Widget)

function WidgetStar:init(config)
	local initialDelay = config.initialDelay
	
	self.imagetables = {}
	self.frametimers = {}
	
	self.tick = 1
	
	local tickValues = {
		initialDelay, 40, 40, 40, 300
	}
	local tickValuesSum = {}
	local sum = 0
	for _, v in pairs(tickValues) do
		sum += v
		table.insert(tickValuesSum, sum)
	end
	
	self.timerDuration = sum
	self.tickFunction = function(frametimer)
		if frametimer.value > tickValuesSum[self.tick] then
			self.tick += 1
		end
	end
end

function WidgetStar:_load()
	self.imagetables.star = playdate.graphics.imagetable.new(kAssetsImages.star)
	
	self.frametimers.frametimer = playdate.frameTimer.new(self.timerDuration)
end

function WidgetStar:_draw(rect)
	self.imagetables.star:getImage(self.tick):draw(rect.x, rect.y)
end

function WidgetStar:_update()
	self.tickFunction(self.frametimers.frametimer)
end
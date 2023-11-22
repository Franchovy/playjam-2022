class("WidgetGameOver").extends(Widget)

function WidgetGameOver:init()
	self:supply(Widget.kDeps.samples)
	
	self:createSprite()
	
	self.painters = {}
end

function WidgetGameOver:_load()
	self.painters.background = Painter(function(rect)
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		
		local rect = Rect.inset(rect, 30, 30)
		playdate.graphics.fillRoundRect(rect.x, rect.y, rect.w, rect.h, 8)
	end)
	
	self:loadSample(kAssetsSounds.death1)
	self:loadSample(kAssetsSounds.death2)
	
	if math.random(10) < 5 then
		self:playSample(kAssetsSounds.death1)
	else 
		self:playSample(kAssetsSounds.death2)
	end
end

function WidgetGameOver:_draw(rect)
	self.painters.background:draw(rect)
end

function WidgetGameOver:_update()
	
end
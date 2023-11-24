class("WidgetGameOver").extends(Widget)

function WidgetGameOver:init()	
	self:createSprite(kZIndex.overlay)
	self.painters = {}
end

function WidgetGameOver:_load()
	self.painters.background = Painter(function(rect)
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.fillRect(rect.x, rect.y, rect.w, rect.h)
		
		local insetRect = Rect.inset(rect, 30, 30)
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.fillRoundRect(insetRect.x, insetRect.y, insetRect.w, insetRect.h, 8)
		
		local center = Position.center(rect)
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.drawTextAligned("GAME OVER", center.x, center.y, kTextAlignment.center)
	end)
end

function WidgetGameOver:_draw(rect)
	self.painters.background:draw(rect)
end

function WidgetGameOver:_update()
	
end
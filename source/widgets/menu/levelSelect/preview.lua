class("LevelSelectPreview").extends(Widget)

function LevelSelectPreview:init()
	self.painters = {}
end

function LevelSelectPreview:load()
	self.painters.background = Painter(function(rect)
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.setDitherPattern(0.5, playdate.graphics.image.kDitherTypeDiagonalLine)
		playdate.graphics.fillRect(rect.x, rect.y, rect.w, rect.h)
	end)
	
	self.painters.scoreCard = Painter(function(rect)
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.setDitherPattern(0.3, playdate.graphics.image.kDitherTypeScreen)
		playdate.graphics.setLineWidth(2)
		playdate.graphics.fillRoundRect(rect.x, rect.y, rect.w, rect.h, 8)
		
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		local fillRect = Rect.inset(rect, 2, 2)
		playdate.graphics.fillRoundRect(fillRect.x, fillRect.y - 1, fillRect.w, fillRect.h, 6)
	end)
end

function LevelSelectPreview:draw(rect)
	self.painters.background:draw(rect)
	self.painters.scoreCard:draw(Rect.inset(rect, 8, 45))
end

function LevelSelectPreview:update()
	
end

function LevelSelectPreview:changeState(stateFrom, stateTo)
	
end
import "assets"

class("LevelSelectPreview").extends(Widget)

function LevelSelectPreview:init()
	self.images = {}
	self.painters = {}
end

function LevelSelectPreview:_load()
	self.images.star = playdate.graphics.image.new(kAssetsImages.starMenu):scaledImage(0.5)
	self.images.labelCoins = playdate.graphics.imageWithText("COINS", 100, 20)
	self.images.labelTime = playdate.graphics.imageWithText("TIME", 100, 20)
	
	local background = Painter(function(rect)
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.setDitherPattern(0.3, playdate.graphics.image.kDitherTypeScreen)
		playdate.graphics.setLineWidth(2)
		playdate.graphics.fillRoundRect(rect.x, rect.y, rect.w, rect.h, 8)
		
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		local fillRect = Rect.inset(rect, 2, 2)
		playdate.graphics.fillRoundRect(fillRect.x, fillRect.y - 1, fillRect.w, fillRect.h, 6)
	end)
	
	local layout = Painter(function(rect)
		local starSize = self.images.star:getSize()
		self.images.star:draw(rect.x + 15, rect.y + 70)
		self.images.star:draw(rect.x + 15 + starSize + 10, rect.y + 70)
		self.images.star:draw(rect.x + 15 + (starSize + 10) * 2, rect.y + 70)
		
		self.images.labelCoins:draw(rect.x + 10, rect.y + 110)
		self.images.labelTime:draw(rect.x + 90, rect.y + 110)
	end)
	
	self.painters.painter = Painter(function(rect)
		background:draw(rect)
		layout:draw(rect)
	end)
end

function LevelSelectPreview:_draw(rect)
	self.painters.painter:draw(Rect.inset(rect, 8, 45))
end

function LevelSelectPreview:_update()
	
end

function LevelSelectPreview:changeState(stateFrom, stateTo)
	
end
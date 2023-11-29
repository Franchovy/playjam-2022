class("WidgetHUD").extends(Widget)

function WidgetHUD:init()
	self:supply(Widget.kDeps.state)
	self:setStateInitial(nil, {time = 0, coins = 0})
	
	self.images = {}
	self.painters = {}
end

function WidgetHUD:_load()
	self.images.coin = playdate.graphics.image.new(kAssetsImages.coin)
	
	self:refreshImages()
	
	self.painters.frame = Painter(function(rect)
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.setLineWidth(2)
		playdate.graphics.drawRoundRect(rect.x, rect.y, rect.w, rect.h, 6)
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.setDitherPattern(0.25, playdate.graphics.image.kDitherTypeDiagonalLine)
		playdate.graphics.setLineWidth(1)
		
		local insetRect = Rect.inset(rect, 2, 2)
		playdate.graphics.fillRoundRect(insetRect.x, insetRect.y, insetRect.w, insetRect.h, 6)
	end)
end

function WidgetHUD:_draw(rect)
	self.painters.frame:draw(rect)
	
	self.images.timeLabel:draw(rect.x + 10, rect.y + 7)
	
	local imageLabelCoinWidth = self.images.coinsLabel:getSize()
	local imageCoinSize = self.images.coin:getSize()
	
	self.images.coinsLabel:draw(rect.x + rect.w - (10 * 2) - imageCoinSize - imageLabelCoinWidth, rect.y + 7)
	self.images.coin:draw(rect.x + rect.w - 10 - imageCoinSize, rect.y + 3)
end

function WidgetHUD:_update()
	
end

function WidgetHUD:changeState(_, stateTo)
	self:refreshImages()
end

function WidgetHUD:refreshImages()
	local timeLabelText = convertToTimeString(self.state.time, 2)
	self.images.timeLabel = playdate.graphics.imageWithText(timeLabelText, 100, 15):scaledImage(2)
	
	self.images.coinsLabel = playdate.graphics.imageWithText(""..self.state.coins, 100, 15):scaledImage(2)
end
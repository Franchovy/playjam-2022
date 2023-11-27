class("WidgetGameOver").extends(Widget)

function WidgetGameOver:init(config)
	self.config = config
	self.painters = {}
	self.images = {}
	
	self:createSprite(kZIndex.overlay)
end

function WidgetGameOver:_load()
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	self.images.gameOverText = playdate.graphics.imageWithText("GAME OVER", 100, 70):scaledImage(3)
	self.images.gameOverReason = playdate.graphics.imageWithText(self.config.reason, 150, 70)
	
	self.painters.background = Painter(function(rect)
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.fillRect(rect.x, rect.y, rect.w, rect.h)
		
		local insetRect = Rect.inset(rect, 30, 30)
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.fillRoundRect(insetRect.x, insetRect.y, insetRect.w, insetRect.h, 8)
		
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		local gameOverTextSizeW, gameOverTextSizeH = self.images.gameOverText:getSize()
		local gameOverTextCenterRect = Rect.center(Rect.size(gameOverTextSizeW, gameOverTextSizeH), insetRect)
		self.images.gameOverText:draw(gameOverTextCenterRect.x, insetRect.y + 12)
		
		local gameOverReasonSizeW, gameOverReasonSizeH = self.images.gameOverReason:getSize()
		local gameOverReasonCenterRect = Rect.center(Rect.size(gameOverReasonSizeW, gameOverReasonSizeH), insetRect)
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		self.images.gameOverReason:draw(gameOverReasonCenterRect.x, insetRect.y + 47)
	end)
end

function WidgetGameOver:_draw(rect)
	self.painters.background:draw(rect)
end

function WidgetGameOver:_update()
	
end
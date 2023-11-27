import "widgets/common/entriesMenu"

class("WidgetGameOver").extends(Widget)

function WidgetGameOver:init(config)
	self.config = config
	
	self.painters = {}
	self.images = {}
	
	self:supply(Widget.kDeps.children)
	
	self:createSprite(kZIndex.overlay)
end

function WidgetGameOver:_load()
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	self.images.gameOverText = playdate.graphics.imageWithText("GAME OVER", 100, 70):scaledImage(3)
	self.images.gameOverReason = playdate.graphics.imageWithText(self.config.reason, 150, 70)
	
	self.painters.background = Painter(function(rect)
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.fillRect(rect.x, rect.y, rect.w, rect.h)
	end)
	
	self.painters.content = Painter(function(rect)
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.fillRoundRect(rect.x, rect.y, rect.w, rect.h, 8)
		
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		local gameOverTextSizeW, gameOverTextSizeH = self.images.gameOverText:getSize()
		local gameOverTextCenterRect = Rect.center(Rect.size(gameOverTextSizeW, gameOverTextSizeH), rect)
		self.images.gameOverText:draw(gameOverTextCenterRect.x, rect.y + 12)
		
		local gameOverReasonSizeW, gameOverReasonSizeH = self.images.gameOverReason:getSize()
		local gameOverReasonCenterRect = Rect.center(Rect.size(gameOverReasonSizeW, gameOverReasonSizeH), rect)
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		self.images.gameOverReason:draw(gameOverReasonCenterRect.x, rect.y + 47)
	end)
	
	self.children.entriesMenu = Widget.new(WidgetEntriesMenu, self.config.options)
	self.children.entriesMenu:load()
	
	self.children.entriesMenu.signals.entrySelected = function(entry)
		self.config.entrySelectedCallback(entry)
	end
end

function WidgetGameOver:_draw(rect)
	self.painters.background:draw(rect)
	
	local insetRect = Rect.inset(rect, 30, 30)
	self.painters.content:draw(insetRect)
	
	self.children.entriesMenu:draw(Rect.inset(insetRect, 10, 60, nil, 15))
end

function WidgetGameOver:_update()
	
	--self.children.entriesMenu:update()
	
end
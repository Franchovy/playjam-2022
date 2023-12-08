import "assets"

class("LevelSelectPreview").extends(Widget)

function LevelSelectPreview:init(config)
	self.config = config
	
	self.images = {}
	self.painters = {}
	
	--
	
	self.data = {}
end

function LevelSelectPreview:_load()
	self.images.level = playdate.graphics.image.new(self.config.imagePath)
	self.images.star = playdate.graphics.image.new(kAssetsImages.starMenu):scaledImage(0.5)
	
	local scoreCoins
	if self.config.score ~= nil then
		scoreCoins = self.config.score.coinCount.."/"..self.config.score.coinCountObjective
	else
		scoreCoins = "-"
	end
	
	local scoreTime
	if self.config.score ~= nil then
		scoreTime = self.config.score.timeString.."/"..self.config.score.timeStringObjective
	else
		scoreTime = "-"
	end
	
	self.images.labelCoins = playdate.graphics.imageWithText(scoreCoins, 100, 20)
	self.images.labelTime = playdate.graphics.imageWithText(scoreTime, 100, 20)
	self.images.labelTitle = playdate.graphics.imageWithText(self.config.title, 100, 20):scaledImage(1.5)
	self.images.labelMissing = playdate.graphics.imageWithText("NO HIGHSCORE", 200, 20)
	
	local scoreStars
	if self.config.score ~= nil then
		scoreStars = self.config.score.stars
	else
		scoreStars = nil
	end
	self.data.starsCount = scoreStars
	
	self.painters.star = Painter(function(rect)
		playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillBlack)
		self.images.star:draw(rect.x, rect.y)
		
		playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeCopy)
		self.images.star:drawFaded(rect.x, rect.y, 0.9, playdate.graphics.image.kDitherTypeDiagonalLine)
	end)
	
	self.painters.background = Painter(function(rect)
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.setDitherPattern(0.3, playdate.graphics.image.kDitherTypeScreen)
		playdate.graphics.setLineWidth(2)
		playdate.graphics.fillRoundRect(rect.x, rect.y, rect.w, rect.h, 8)
		
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		local fillRect = Rect.inset(rect, 2, 2)
		playdate.graphics.fillRoundRect(fillRect.x, fillRect.y - 1, fillRect.w, fillRect.h, 6)
	end)
	
	local noHighScore = Painter(function(rect)
		local labelImageW, labelImageH = self.images.labelMissing:getSize()
		self.images.labelMissing:draw(rect.x + (rect.w - labelImageW) / 2, rect.y + (rect.h - labelImageH) / 2)
	end)
	
	local layout = Painter(function(rect, state)
		local starSize = self.images.star:getSize()
		
		local starOffsetInitial
		local starOffset
		if state.starsCount > 3 then
			starOffsetInitial = rect.x + 2
			starOffset = starSize + 5
		else
			starOffsetInitial = rect.x + 15
			starOffset = starSize + 10
		end
		
		local starImageW, starImageH = self.images.star:getSize()
		local starRect = Rect.make(0, rect.y, starImageW, starImageH)
		for i=1, state.starsCount do
			self.painters.star:draw(Rect.with(starRect, {x = starOffsetInitial + (starOffset * (i - 1))}))
		end
		
		self.images.labelCoins:draw(rect.x, rect.y + starImageH + 5)
		
		local labelTimeImageWidth, labelHeight = self.images.labelTime:getSize()
		self.images.labelTime:draw(rect.x + rect.w - labelTimeImageWidth, rect.y + starImageH + 5)
	end)
	
	self.painters.contents = Painter(function(rect, state)
		local _, levelImageSizeH = self.images.level:getSize()
		self.images.level:draw(7, 10)
		
		local labelTitleSizeW, labelTitleSizeH = self.images.labelTitle:getSize()
		self.images.labelTitle:draw(rect.x + (rect.w - labelTitleSizeW) / 2, 10 + levelImageSizeH + 5)
		
		local insetRect = Rect.inset(rect, 5, 10 + levelImageSizeH + 5 + labelTitleSizeH + 5, 5, 7)
		if state.starsCount ~= nil then
			layout:draw(insetRect, state)
		else
			noHighScore:draw(insetRect, state)
		end
	end)
end

function LevelSelectPreview:_draw(rect)
	local insetRect = Rect.inset(rect, 8, 35)
	
	self.painters.background:draw(insetRect)
	
	self.painters.contents:draw(insetRect, { starsCount = self.data.starsCount })
end

function LevelSelectPreview:_update()
	
end

import "levelComplete/star"

class("LevelComplete").extends(Widget)

function LevelComplete:init(config)
	
	self.levelDarkMode = config.levelDarkMode
	self.numStars = config.stars
	self.coins = config.coinCount
	self.coinsObjective = config.coinCountObjective
	self.time = config.timeString
	self.timeObjective = config.timeStringObjective
	
	self:supply(Widget.kDeps.samples)
	self:supply(Widget.kDeps.state)
	
	self:setStateInitial({
		text = 1,
		overlay = 2
	}, 1)
	
	self.painters = {}
	self.images = {}
	self.blinkers = {}
	self.children = {}
	
	self.previousBlink = false
end

function LevelComplete:_load()
	
	self:loadSample(kAssetsSounds.levelCompleteBlink, 0.7)
	self:loadSample(kAssetsSounds.levelCompleteCard, 0.7)
	
	self.images.titleInGame = playdate.graphics.imageWithText("LEVEL COMPLETE", 200, 70):scaledImage(3)
	self.images.titleInGame:setInverted(self.levelDarkMode) 

	self.images.title = playdate.graphics.imageWithText("LEVEL COMPLETE!", 200, 70):scaledImage(2)
	
	self.images.coin = playdate.graphics.image.new(kAssetsImages.coin):scaledImage(0.45)
	
	self.images.textLabelCoins = playdate.graphics.imageWithText("COINS", 60, 100)
	self.images.textLabelTime = playdate.graphics.imageWithText("TIME", 60, 100)
	
	local coinsText = self.coins .. "/".. self.coinsObjective
	local timeText = self.time .. "/".. self.timeObjective
	self.images.textCoins = playdate.graphics.imageWithText(coinsText, 100, 40):scaledImage(2)
	self.images.textTime = playdate.graphics.imageWithText(timeText, 100, 40):scaledImage(2)
	
	self.images.textPressAButton = playdate.graphics.imageWithText("PRESS A", 80, 40):scaledImage(2)

	self.blinkers.blinkerTitle = playdate.graphics.animation.blinker.new(300, 100)
	self.blinkers.blinkerTitle:startLoop()
	
	self.blinkers.blinkerPressAButton1 = playdate.graphics.animation.blinker.new(800, 100)
	self.blinkers.blinkerPressAButton2 = playdate.graphics.animation.blinker.new(700, 200)
	
	self.painters.background = Painter(function(rect)
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.setLineWidth(6)
		playdate.graphics.drawRoundRect(rect.x, rect.y, rect.w, rect.h, 16)
		
		local insetRect = Rect.inset(rect, 4, 4)
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.setLineWidth(4)
		playdate.graphics.drawRoundRect(insetRect.x, insetRect.y, insetRect.w, insetRect.h, 4)
		
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.setDitherPattern(0.1, playdate.graphics.image.kDitherTypeDiagonalLine)
		playdate.graphics.fillRoundRect(insetRect.x, insetRect.y, insetRect.w, insetRect.h, 8)
	end)
	
	self.painters.pressAButton = Painter(function(rect, state)
		local fgColor
		local drawMode
		
		if state.inverted == false then
			fgColor = playdate.graphics.kColorBlack
			drawMode = playdate.graphics.kDrawModeCopy
		elseif state.inverted == true then 
			fgColor = playdate.graphics.kColorWhite
			drawMode = playdate.graphics.kDrawModeInverted
		end
		
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.fillRoundRect(rect.x, rect.y, rect.w, rect.h, 4)
		
		local insetRect = Rect.inset(rect, 2, 2)
		playdate.graphics.setColor(fgColor)
		playdate.graphics.setDitherPattern(0.4, playdate.graphics.image.kDitherTypeDiagonalLine)
		playdate.graphics.fillRoundRect(insetRect.x, insetRect.y, insetRect.w, insetRect.h, 2)
		
		playdate.graphics.setImageDrawMode(drawMode)
		self.images.textPressAButton:invertedImage():draw(rect.x + 12, rect.y + 4)
		playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeCopy)
	end)
	
	self.stars = {}
	for i=1, self.numStars do
		local star = Widget.new(WidgetStar, { initialDelay = 100 + i * 700 })
		star:load()
		table.insert(self.stars, star)
		self.children["star"..i] = star
	end
end

function LevelComplete:_draw(rect)
	if self.state == self.kStates.text then
		if self.blinkers.blinkerTitle.on then
			if self.previousBlink == false then
				self:playSample(kAssetsSounds.levelCompleteBlink)
				self.previousBlink = true
			end
			
			self.images.titleInGame:drawCentered(rect.x + rect.w / 2, rect.y + 100)
		else 
			self.previousBlink = false
		end
	end
	
	if self.state == self.kStates.overlay then
		self.painters.background:draw(rect)
		
		local titleImageY = rect.y + 8
		self.images.title:drawCentered(rect.x + rect.w / 2, rect.y + titleImageY)
		
		local starImageWidth, starImageHeight = self.stars[1].imagetables.star:getImage(1):getSize()
		local starMargin
		local starContainerWidth
		
		function starsContentWidth(numStars)
			return (starImageWidth * numStars) + starMargin * (numStars - 1)
		end
		
		if self.numStars <= 3 then 
			starMargin = 20
			starContainerWidth = starsContentWidth(3)
		elseif self.numStars == 4 then
			starMargin = 5
			starContainerWidth = starsContentWidth(4)
		end
		
		local starImageY = rect.y + titleImageY + 12
		
		for i, star in ipairs(self.stars) do
			local contentRect = Rect.size(starContainerWidth, starImageHeight)
			local centeredRect = Rect.center(contentRect, rect)
			
			self.stars[i]:draw(Rect.make(centeredRect.x + (starImageWidth + starMargin) * (i - 1), starImageY, starImageWidth, starImageHeight))
		end
		
		local textCoinsWidth, textHeight = self.images.textCoins:getSize()
		local textTimeWidth, _ = self.images.textTime:getSize()
		local textImagesY = starImageY + starImageHeight + 26
		local sideMarginText = 8
		
		self.images.textCoins:draw(rect.x + sideMarginText, textImagesY)
		self.images.textTime:draw(rect.x + rect.w - sideMarginText - textTimeWidth, textImagesY)
		
		local coinImageWidth, coinImageHeight = self.images.coin:getSize()
		local labelWidth, labelHeight = self.images.textLabelCoins:getSize()
		
		self.images.coin:draw(rect.x + sideMarginText + (textCoinsWidth - labelWidth) / 2, textImagesY - 8 - (labelHeight + coinImageHeight) / 2)
		
		self.images.textLabelCoins:draw(rect.x + sideMarginText + coinImageWidth + 5 + (textCoinsWidth - labelWidth) / 2, textImagesY - 8 - labelHeight)
		self.images.textLabelTime:draw(rect.x + rect.w - sideMarginText - (textTimeWidth + labelWidth) / 2, textImagesY - 8 - labelHeight)
		
		local buttonTextWidth, buttonTextHeight = self.images.textPressAButton:getSize()
		local buttonRect = Rect.with(Rect.center(Rect.inset(Rect.size(buttonTextWidth, buttonTextHeight), -12, -4), rect), { y = rect.y + rect.h - buttonTextHeight - 19 })
		
		local blinker1 = self.blinkers.blinkerPressAButton1.on
		local blinker2 = self.blinkers.blinkerPressAButton2.on
		self.painters.pressAButton:draw(buttonRect, { 
			inverted = (not blinker1 and blinker2) or (not blinker2 and blinker1) 
		})
	end
end

function LevelComplete:_update()
	if playdate.buttonJustPressed(playdate.kButtonA) then
		
	end
end

function LevelComplete:changeState(stateFrom, stateTo)
	if stateFrom == self.kStates.text and (stateTo == self.kStates.overlay) then
		self:playSample(kAssetsSounds.levelCompleteCard)
		
		self.blinkers.blinkerTitle:remove()
		
		for _, star in pairs(self.stars) do
			star.timers.timer:start()
		end
		
		playdate.timer.performAfterDelay(100 + #self.stars * 700 + 700, function()
			self.blinkers.blinkerPressAButton1:startLoop()
			self.blinkers.blinkerPressAButton2:startLoop()
		end)
	end
end
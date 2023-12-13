import "levelComplete/star"
import "utils/drawMode"

class("LevelComplete").extends(Widget)

function LevelComplete:init(config)
	self.config = config
	
	self:supply(Widget.kDeps.samples)
	self:supply(Widget.kDeps.state)
	self:supply(Widget.kDeps.children)
	self:supply(Widget.kDeps.animators)
	
	self:setStateInitial({
		text = 1,
		overlay = 2,
		menu = 3
	}, 1)
	
	self.painters = {}
	self.images = {}
	self.blinkers = {}
	
	self.previousBlink = false
	
	self.signals = {}
end

function LevelComplete:_load()
	
	self:loadSample(kAssetsSounds.levelCompleteBlink, 0.7)
	self:loadSample(kAssetsSounds.levelCompleteCard, 0.7)
	
	local drawMode = getColorDrawModeFill(self.config.titleColor)
	playdate.graphics.setImageDrawMode(drawMode)
	self.images.titleInGame = playdate.graphics.imageWithText("LEVEL COMPLETE", 200, 70):scaledImage(3)
	
	playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeCopy)

	self.images.title = playdate.graphics.imageWithText("LEVEL COMPLETE!", 200, 70):scaledImage(2)
	
	self.images.coin = playdate.graphics.image.new(kAssetsImages.coin)
	
	self.images.textLabelCoins = playdate.graphics.imageWithText("COINS", 60, 100):scaledImage(1.5)
	self.images.textLabelTime = playdate.graphics.imageWithText("TIME", 60, 100):scaledImage(1.5)
	
	local coinsText = self.config.objectives.coinCount .. "/".. self.config.objectives.coinCountObjective
	local timeText = self.config.objectives.timeString .. "/".. self.config.objectives.timeStringObjective
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
	for i=1, self.config.objectives.stars do
		local star = Widget.new(WidgetStar, { initialDelay = 100 + i * 700 })
		star:load()
		table.insert(self.stars, star)
		self.children["star"..i] = star
	end
	
	self.animators.card = playdate.graphics.animator.new(0, 0, 0)	
	
	self.children.menu = Widget.new(WidgetEntriesMenu, {
		entries = {
			"NEXT LEVEL",
			"RESTART",
			"MAIN MENU"
		},
		scaleFactor = 1.5
	})
	
	self.children.menu:load()
	self.children.menu:setVisible(false)
	
	self.children.menu.signals.entrySelected = function(entry)
		if entry == 1 then
			self.signals.nextLevel()
		elseif entry == 2 then
			self.signals.restartLevel()
		elseif entry == 3 then
			self.signals.returnToMenu()
		end
	end
end

function LevelComplete:_draw(rect)
	if self.state == self.kStates.text then
		if self.blinkers.blinkerTitle.on then
			self.images.titleInGame:drawCentered(rect.x + rect.w / 2, rect.y + 100)
		end
	end
	
	if self.state == self.kStates.overlay or (self.state == self.kStates.menu) then
		local offsetRect = Rect.offset(rect, 0, self.animators.card:currentValue())
		
		self.painters.background:draw(offsetRect)
		
		local titleImageY = offsetRect.y + 8
		self.images.title:drawCentered(offsetRect.x + offsetRect.w / 2, offsetRect.y + titleImageY)
		
		local starImageWidth, starImageHeight = self.stars[1].imagetables.star:getImage(1):getSize()
		local starMargin
		local starContainerWidth
		
		function starsContentWidth(numStars)
			return (starImageWidth * numStars) + starMargin * (numStars - 1)
		end
		
		if self.config.objectives.stars <= 3 then
			starMargin = 20
			starContainerWidth = starsContentWidth(3)
		elseif self.config.objectives.stars == 4 then
			starMargin = 5
			starContainerWidth = starsContentWidth(4)
		end
		
		local starImageY = offsetRect.y + titleImageY + 12
		
		for i, star in ipairs(self.stars) do
			local contentRect = Rect.size(starContainerWidth, starImageHeight)
			local centeredRect = Rect.center(contentRect, offsetRect)
			
			self.stars[i]:draw(Rect.make(centeredRect.x + (starImageWidth + starMargin) * (i - 1), starImageY, starImageWidth, starImageHeight))
		end
		
		local contentRect = Rect.inset(offsetRect, 8, starImageY + starImageHeight - 16, 8, 8)
		
		if self.state == self.kStates.overlay then
			local labelCoinsWidth, labelCoinsHeight = self.images.textLabelCoins:getSize()
			local labelTimeWidth, labelTimeHeight = self.images.textLabelTime:getSize()
			local textCoinsWidth, textHeight = self.images.textCoins:getSize()
			local textTimeWidth, _ = self.images.textTime:getSize()
			local coinImageWidth, coinImageHeight = self.images.coin:getSize()
			
			self.images.textLabelCoins:draw(contentRect.x + coinImageWidth + 5 + (textCoinsWidth - labelCoinsWidth - coinImageHeight) / 2, contentRect.y)
			self.images.coin:draw(contentRect.x + (textCoinsWidth - labelCoinsWidth - coinImageHeight) / 2, contentRect.y + (labelCoinsHeight - coinImageHeight) / 2)
			self.images.textLabelTime:draw(contentRect.x + contentRect.w - (textTimeWidth + labelTimeWidth) / 2, contentRect.y)
			
			self.images.textCoins:draw(contentRect.x, contentRect.y + labelCoinsHeight + 12)
			self.images.textTime:draw(contentRect.x + contentRect.w - textTimeWidth, contentRect.y + labelTimeHeight + 12)
			
			local buttonTextWidth, buttonTextHeight = self.images.textPressAButton:getSize()
			local buttonRect = Rect.inset(Rect.size(buttonTextWidth, buttonTextHeight), -12, -4)
			local buttonRectPositioned = Rect.with(buttonRect, { x = contentRect.x + (contentRect.w - buttonRect.w) / 2, y = contentRect.y + contentRect.h - buttonRect.h })
			
			local blinker1 = self.blinkers.blinkerPressAButton1.on
			local blinker2 = self.blinkers.blinkerPressAButton2.on
			self.painters.pressAButton:draw(buttonRectPositioned, { 
				inverted = (not blinker1 and blinker2) or (not blinker2 and blinker1) 
			})
		elseif self.state == self.kStates.menu then
			local offsetContentRect = Rect.offset(contentRect, 75, -8)
			self.children.menu:draw(offsetContentRect)
		end
	end
end

function LevelComplete:_update()
	if self.state == self.kStates.text then
		if self.blinkers.blinkerTitle ~= self.previousBlinkTitle then
			playdate.graphics.sprite.addDirtyRect(10, 100, 380, 40)
		end
		
		if self.blinkers.blinkerTitle.on then
			if self.previousBlinkTitle == false then
				self:playSample(kAssetsSounds.levelCompleteBlink)
				self.previousBlinkTitle = true
			end
		else 
			self.previousBlinkTitle = false
		end
	end
	
	if self.state == self.kStates.overlay or (self.state == self.kStates.menu) then
		if self:isAnimating() then
			playdate.graphics.sprite.addDirtyRect(0, 0, 400, 240)
		end
		
		for _, star in pairs(self.stars) do
			if self.wasAnimating == true then
				playdate.graphics.sprite.addDirtyRect(50, 60, 290, 70)
			end
			self.wasAnimating = star:isAnimating()
		end
	end
	
	if self.state == self.kStates.overlay then
		local blinker1 = self.blinkers.blinkerPressAButton1.on
		local blinker2 = self.blinkers.blinkerPressAButton2.on
		
		local blink = (not blinker1 and blinker2) or (not blinker2 and blinker1) 
		if self.previousBlinkButton ~= blink then
			playdate.graphics.sprite.addDirtyRect(110, 185, 180, 28)
		end
		self.previousBlinkButton = blink
	end
	
	if self.state == self.kStates.menu then
		
		local menuIsVisible = self.children.menu:isVisible()
		if menuIsVisible ~= self.previousVisibleMenu then
			playdate.graphics.sprite.addDirtyRect(37, 130, 326, 85)
		end
		self.previousVisibleMenu = menuIsVisible
	end
	
	if playdate.buttonJustPressed(playdate.kButtonA) then
		if self.state == self.kStates.overlay then
			self:setState(self.kStates.menu)
		end
	end
end

function LevelComplete:changeState(stateFrom, stateTo)
	if stateFrom == self.kStates.text and (stateTo == self.kStates.overlay) then
		self:playSample(kAssetsSounds.levelCompleteCard)
		
		self.animators.card = playdate.graphics.animator.new(300, -240, 0, playdate.easingFunctions.outQuint)
		
		self.blinkers.blinkerTitle:remove()
		
		for _, star in pairs(self.stars) do
			star.timers.timer:start()
		end
		
		playdate.timer.performAfterDelay(100 + #self.stars * 700 + 700, function()
			self.blinkers.blinkerPressAButton1:startLoop()
			self.blinkers.blinkerPressAButton2:startLoop()
		end)
	elseif stateFrom == self.kStates.overlay and (stateTo == self.kStates.menu) then
		playdate.timer.performAfterDelay(100, function()
			self.children.menu:setVisible(true)
		end)
	end
end

function LevelComplete:_unload()
	
	self:unloadSample(kAssetsSounds.levelCompleteBlink)
	self:unloadSample(kAssetsSounds.levelCompleteCard)
	
	self.images.titleInGame = nil
	self.images.title = nil
	self.images.coin = nil
	
	self.images.textLabelCoins = nil
	self.images.textLabelTime = nil
	
	self.images.textCoins = nil
	self.images.textTime = nil
	
	self.images.textPressAButton = nil
	
	self.blinkers.blinkerTitle = nil
	
	self.blinkers.blinkerPressAButton1 = nil
	self.blinkers.blinkerPressAButton2 = nil
	
	self.painters.background = nil
	
	self.painters.pressAButton:unload()
	self.painters.pressAButton = nil
	
	for i=1, #self.stars do
		self.stars[i] = nil
		self.children["star"..i] = star
	end
	
	self.stars = nil
	self.animators.card = nil
	
	self.children.menu:unload()
	self.children.menu = nil
end
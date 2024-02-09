import "levelComplete/star"
import "utils/drawMode"

local gfx <const> = playdate.graphics
local easing <const> = playdate.easingFunctions
local timer <const> = playdate.timer

class("LevelComplete").extends(Widget)

function LevelComplete:_init()
	self:supply(Widget.deps.samples)
	self:supply(Widget.deps.state)
	self:supply(Widget.deps.animators)
	self:supply(Widget.deps.input)
	
	self:setStateInitial(1, {
		"text",
		"overlay",
		"menu",
	})
	
	self.painters = {}
	self.images = {}
	self.blinkers = {}
	
	self.previousBlink = false
	
	self.signals = {}
end

function LevelComplete:_load()
	
	self:loadSample(kAssetsSounds.levelCompleteBlink, 0.7)
	self:loadSample(kAssetsSounds.levelCompleteCard, 0.7)
	self:loadSample(kAssetsSounds.menuAccept)
	
	local drawMode = getColorDrawModeFill(self.config.titleColor)
	gfx.setImageDrawMode(drawMode)
	self.images.titleInGame = gfx.imageWithText("LEVEL COMPLETE", 200, 70):scaledImage(3)
	
	gfx.setImageDrawMode(gfx.kDrawModeCopy)

	self.images.coin = gfx.image.new(kAssetsImages.coin)
	
	self.images.background = gfx.image.new(400, 240, gfx.kColorBlack):fadedImage(0.6, gfx.image.kDitherTypeHorizontalLine)
	
	self.images.textPressAButton = gfx.imageWithText("PRESS A", 80, 40):scaledImage(2)

	self.blinkers.blinkerTitle = gfx.animation.blinker.new(300, 100)
	self.blinkers.blinkerTitle:startLoop()
	
	self.blinkers.blinkerPressAButton1 = gfx.animation.blinker.new(800, 100)
	self.blinkers.blinkerPressAButton2 = gfx.animation.blinker.new(700, 200)
	
	self.painters.containerBackgroundStars = Painter(function(rect)
		gfx.setColor(gfx.kColorWhite)
		gfx.setLineWidth(6)
		gfx.drawRoundRect(rect.x, rect.y, rect.w, rect.h, 16)
		
		local insetRect = Rect.inset(rect, 4, 4)
		gfx.setColor(gfx.kColorBlack)
		gfx.setLineWidth(4)
		gfx.drawRoundRect(insetRect.x, insetRect.y, insetRect.w, insetRect.h, 4)
		
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRoundRect(insetRect.x, insetRect.y, insetRect.w, insetRect.h, 8)
		
		gfx.setColor(gfx.kColorBlack)
		gfx.setDitherPattern(0.4, gfx.image.kDitherTypeDiagonalLine)
		gfx.fillRoundRect(insetRect.x, insetRect.y, insetRect.w, insetRect.h, 8)
	end)
	
	self.painters.frame = Painter(function(rect)
		gfx.setColor(gfx.kColorWhite)
		gfx.setLineWidth(6)
		gfx.drawRoundRect(rect.x, rect.y, rect.w, rect.h, 16)
		
		local insetRect = Rect.inset(rect, 4, 4)
		gfx.setColor(gfx.kColorBlack)
		gfx.setLineWidth(4)
		gfx.drawRoundRect(insetRect.x, insetRect.y, insetRect.w, insetRect.h, 4)
		
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRoundRect(insetRect.x, insetRect.y, insetRect.w, insetRect.h, 8)
	end)
	
	self.painters.pressAButton = Painter(function(rect, state)
		local fgColor
		local drawMode
		
		if state.inverted == false then
			fgColor = gfx.kColorBlack
			drawMode = gfx.kDrawModeCopy
		elseif state.inverted == true then 
			fgColor = gfx.kColorWhite
			drawMode = gfx.kDrawModeInverted
		end
		
		gfx.setColor(gfx.kColorBlack)
		gfx.fillRoundRect(rect.x, rect.y, rect.w, rect.h, 4)
		
		local insetRect = Rect.inset(rect, 2, 2)
		gfx.setColor(fgColor)
		gfx.setDitherPattern(0.4, gfx.image.kDitherTypeDiagonalLine)
		gfx.fillRoundRect(insetRect.x, insetRect.y, insetRect.w, insetRect.h, 2)
		
		gfx.setImageDrawMode(drawMode)
		self.images.textPressAButton:invertedImage():draw(rect.x + 12, rect.y + 4)
		gfx.setImageDrawMode(gfx.kDrawModeCopy)
	end)
	
	self.painters.title = Painter(function(rect)
		setCurrentFont(kAssetsFonts.twinbee2x)
		local textHeight = getFont(kAssetsFonts.twinbee2x):getHeight()
		gfx.drawTextAligned("LEVEL COMPLETE!", rect.x + rect.w / 2, rect.y + textHeight / 2, kTextAlignment.center)
	end)
	
	self.painters.objectives = Painter(function(rect)
		local textHeight15 = getFont(kAssetsFonts.twinbee15x):getHeight()
		local topTextRect = Rect.with(rect, { h = textHeight15 })
		local rectLeft, rectRight = Rect.splitHorizontal(topTextRect, 2)
		
		setCurrentFont(kAssetsFonts.twinbee15x)
		gfx.drawTextAligned("COINS:", rectLeft.x + rectLeft.w / 2, topTextRect.y + topTextRect.h / 2, kTextAlignment.center)
		gfx.drawTextAligned("TIME:", rectRight.x + rectRight.w / 2, topTextRect.y + topTextRect.h / 2, kTextAlignment.center)
		
		local textHeight2 = getFont(kAssetsFonts.twinbee2x):getHeight()
		local topTextRect = Rect.with(rect, { y = topTextRect.y + textHeight15 + 3, h = textHeight2 })
		
		local coinsLabelText = self.config.objectives.coinsString
		local timeLabelText = self.config.objectives.timeString
		
		setCurrentFont(kAssetsFonts.twinbee2x)
		gfx.drawTextAligned(coinsLabelText, rectLeft.x + rectLeft.w / 2, topTextRect.y + topTextRect.h / 2, kTextAlignment.center)
		gfx.drawTextAligned(timeLabelText, rectRight.x + rectRight.w / 2, topTextRect.y + topTextRect.h / 2, kTextAlignment.center)
	end)
	
	self.stars = {}
	for i=1, self.config.objectives.stars do
		local star = Widget.new(WidgetStar, { initialDelay = 100 + i * 700 })
		star:load()
		table.insert(self.stars, star)
		self.children["star"..i] = star
	end
	
	self.animators.card = gfx.animator.new(0, 0, 0)	
	
	self.children.menu = Widget.new(WidgetEntriesMenu, {
		entries = {
			"NEXT LEVEL",
			"RESTART",
			"MAIN MENU"
		},
		scale = 1.5,
		shouldDrawFrame = true
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
		
		self.images.background:drawFaded(0, 0, self.animators.card:progress(), gfx.image.kDitherTypeDiagonalLine)
		
		self.painters.frame:draw(offsetRect)
		
		local titleRect = Rect.with(Rect.offset(offsetRect, 0, 2), { h = 25 })
		self.painters.title:draw(titleRect)
		
		local starImageWidth, starImageHeight = self.stars[1].imagetables.star:getImage(1):getSize()
		
		local frameStarCount = math.max(self.config.objectives.stars, 3)
		local margin = frameStarCount == 3 and 20 or 5
		local rectStarContainer = Rect.with(Rect.inset(offsetRect, 7, 0), { y = Rect.bottom(titleRect) + 5, h = starImageHeight + 10 })
		local rectStarContent = Rect.center(Rect.size((starImageWidth + margin) * frameStarCount - margin, starImageHeight), rectStarContainer)
		local starRects = { Rect.splitHorizontal(rectStarContent, frameStarCount) }
		
		self.painters.containerBackgroundStars:draw(rectStarContainer)
		
		for i, star in ipairs(self.stars) do
			self.stars[i]:draw(starRects[i])
		end
		
		local rectContentBottom = Rect.inset(offsetRect, 8, rectStarContainer.y + rectStarContainer.h - 16, 8, 8)
		
		if self.state == self.kStates.overlay then
			self.painters.objectives:draw(rectContentBottom)
			
			local buttonTextWidth, buttonTextHeight = self.images.textPressAButton:getSize()
			local buttonRect = Rect.inset(Rect.size(buttonTextWidth, buttonTextHeight), -12, -4)
			local buttonRectPositioned = Rect.with(buttonRect, { x = rectContentBottom.x + (rectContentBottom.w - buttonRect.w) / 2, y = rectContentBottom.y + rectContentBottom.h - buttonRect.h })
			
			local blinker1 = self.blinkers.blinkerPressAButton1.on
			local blinker2 = self.blinkers.blinkerPressAButton2.on
			self.painters.pressAButton:draw(buttonRectPositioned, { 
				inverted = (not blinker1 and blinker2) or (not blinker2 and blinker1) 
			})
		elseif self.state == self.kStates.menu then
			local rectMenu = Rect.with(Rect.offset(rectContentBottom, 70, 2), { w = 180, h = 70 })
			self.children.menu:draw(rectMenu)
		end
	end
end

function LevelComplete:_update()
	if self.state == self.kStates.text then
		if self.blinkers.blinkerTitle ~= self.previousBlinkTitle then
			gfx.sprite.addDirtyRect(10, 100, 380, 40)
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
		if self:wasAnimating() == true then
			gfx.sprite.addDirtyRect(0, 0, 400, 240)
		end
		
		for _, star in pairs(self.stars) do
			if star:wasAnimating() == true then
				gfx.sprite.addDirtyRect(50, 60, 290, 70)
			end
		end
	end
	
	if self.state == self.kStates.overlay then
		self:filterInput(playdate.kButtonA | playdate.kButtonB)
		
		local blinker1 = self.blinkers.blinkerPressAButton1.on
		local blinker2 = self.blinkers.blinkerPressAButton2.on
		
		local blink = (not blinker1 and blinker2) or (not blinker2 and blinker1) 
		if self.previousBlinkButton ~= blink then
			gfx.sprite.addDirtyRect(110, 185, 180, 28)
		end
		self.previousBlinkButton = blink
	end
	
	if self.state == self.kStates.menu then
		self:passInput(self.children.menu)
		
		local menuIsVisible = self.children.menu:isVisible()
		if menuIsVisible ~= self.menuWasVisible then
			gfx.sprite.addDirtyRect(37, 130, 326, 85)
		end
		self.menuWasVisible = menuIsVisible
	end
end

function LevelComplete:_handleInput(input)
	if self.state ~= self.kStates.overlay then
		return
	end
		
	if input.pressed & (playdate.kButtonA | playdate.kButtonB) ~= 0 then
		self:playSample(kAssetsSounds.menuAccept)
		
		self:setState(self.kStates.menu)
	end
end

function LevelComplete:_changeState(stateFrom, stateTo)
	if stateFrom == self.kStates.text and (stateTo == self.kStates.overlay) then
		self:playSample(kAssetsSounds.levelCompleteCard)
		
		self.animators.card = gfx.animator.new(300, -240, 0, easing.outQuint)
		
		self.blinkers.blinkerTitle:remove()
		
		for _, star in pairs(self.stars) do
			star.timers.timer:start()
		end
		
		timer.performAfterDelay(100 + #self.stars * 700 + 700, function()
		-- Safeguard in case of unloading before timer callback
			if self.blinkers == nil then
				return
			end
			
			self.blinkers.blinkerPressAButton1:startLoop()
			self.blinkers.blinkerPressAButton2:startLoop()
		end)
	elseif stateFrom == self.kStates.overlay and (stateTo == self.kStates.menu) then
		timer.performAfterDelay(100, function()
			self.children.menu:setVisible(true)
		end)
	end
end

function LevelComplete:_unload()
	self.images = nil
	self.blinkers = nil
	self.painters = nil
	
	for _, child in pairs(self.children) do child:unload() end
	self.children = nil
end
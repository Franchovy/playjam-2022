
function drawLevelClearSprite(stars, coins, targetCoins, time, targetTime)
	local bounds = playdate.display.getRect()
	local x1, y1, width1, height1 = rectInsetBy(bounds, 30, 30)
	local x2, y2, width2, height2 = rectInsetBy(bounds, 34, 36)
	
	local imageCardBackground = playdate.graphics.image.new(width2, height2)
	
	playdate.graphics.pushContext(imageCardBackground)
	
	playdate.graphics.setColor(playdate.graphics.kColorWhite)
	playdate.graphics.fillRoundRect(0, 0, width2, height2, 18)
	
	playdate.graphics.popContext()
	
	local imageCard = playdate.graphics.image.new(width1, height1)
	
	playdate.graphics.pushContext(imageCard)
	
	-- Frame
	
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.fillRoundRect(0, 0, width1, height1, 16)
	playdate.graphics.setColor(playdate.graphics.kColorClear)
	playdate.graphics.fillRoundRect(x2 - x1, (y2 - y1) / 2, width2, height2, 18)
	
	imageCardBackground:fadedImage(0.8, playdate.graphics.image.kDitherTypeDiagonalLine):draw(x2 - x1, (y2 - y1) / 2)
	
	gfx.setFontTracking(1)
	local textImageTitle = createTextImage("LEVEL COMPLETE!"):scaledImage(2)
	
	gfx.setFontTracking(1)
	local textImageCoinsLabel = createTextImage("COINS"):scaledImage(1)
	local textImageTimeLabel = createTextImage("TIME"):scaledImage(1)
	gfx.setFontTracking(0)
	local textImageCoinsValue = createTextImage(coins .. "/".. targetCoins):scaledImage(2)
	local textImageTimeValue = createTextImage(time.. "/".. targetTime):scaledImage(2)
	
	local widthTitle, _ = textImageTitle:getSize()
	textImageTitle:draw((width1 - widthTitle) / 2, 10)
	
	local widthCoinsLabel, heightCoinsLabel = textImageCoinsLabel:getSize()
	local widthCoinsValue, heightCoinsValue = textImageCoinsValue:getSize()
	textImageCoinsLabel:draw(20 + (widthCoinsValue - widthCoinsLabel) / 2, height1 - heightCoinsLabel - 15 - heightCoinsValue - 20)
	textImageCoinsValue:draw(20, height1 - heightCoinsValue - 20)
	
	local widthTimeLabel, heightTimeLabel = textImageTimeLabel:getSize()
	local widthTimeValue, heightTimeValue = textImageTimeValue:getSize()
	textImageTimeLabel:draw(width1 - widthTimeValue + (widthTimeValue - widthTimeLabel) / 2 - 20, height1 - heightTimeLabel - 15 - heightCoinsValue - 20)
	textImageTimeValue:draw(width1 - widthTimeValue - 20, height1 - heightTimeValue - (heightCoinsValue - heightTimeValue) / 2 - 20)
	
	playdate.graphics.popContext()
	
	local sprite = playdate.graphics.sprite.new(imageCard)
	sprite:add()
	sprite:setCenter(0, 0)
	sprite:setIgnoresDrawOffset(true)
	
	-- Button Labels
	
	local buttonALabelText = createTextImage("B - RETRY")
	local buttonALabel = createRoundedRectFrame(buttonALabelText, 4, 8, 5)
	
	local buttonBLabelText = createTextImage("A - LEVELS")
	local buttonBLabel = createRoundedRectFrame(buttonBLabelText, 4, 8, 5)
	
	local buttonBLabelWidth, buttonBLabelHeight = buttonBLabel:getSize()
	local buttonsImage = playdate.graphics.image.new(360, buttonBLabelHeight)
	
	playdate.graphics.pushContext(buttonsImage)
	local margin = 44
	buttonALabel:draw(0, 0)
	buttonBLabel:draw(bounds.width - (margin * 2) - buttonBLabelWidth, 0)
	
	playdate.graphics.popContext(buttonsImage)
	
	local spriteButtons = playdate.graphics.sprite.new(buttonsImage)
	spriteButtons:add()
	spriteButtons:setCenter(0, 0)
	spriteButtons:setIgnoresDrawOffset(true)
	spriteButtons:moveTo(margin, bounds.height - 6 - buttonBLabelHeight)
	
	-- Stars
	
	local imageTable = playdate.graphics.imagetable.new(kAssetsImages.star)
	local starLoops = {}
	for i=1,stars do
		local starLoop = playdate.graphics.animation.loop.new(200, imageTable, true)
		starLoop.paused = true
		table.insert(starLoops, starLoop)
	end
	
	local marginStar
	if stars < 4 then
		marginStar = 20
	else
		marginStar = 5
	end 
	
	local starWidth, starHeight = imageTable:getImage(1):getSize()
	
	local starSprite = playdate.graphics.sprite.new()
	starSprite:setSize(starWidth * stars + marginStar * (stars - 1), starHeight)
	starSprite:setCenter(0, 0)
	starSprite:setIgnoresDrawOffset(true)
	starSprite:setAlwaysRedraw(true)
	
	for _, star in pairs(starLoops) do
		star.paused = false
	end
	
	starSprite.draw = function (self, x, y)
		for i, star in ipairs(starLoops) do
			if stars >= i then
				star:draw((starWidth + marginStar) * (i - 1), 0)
			end
		end
	end
	
	starSprite:add()
	starSprite:moveTo(50 + marginStar, 65)
	
	-- Animations
	
	local animationStartPosition = 240
	local animationEndPosition = y1
	
	sprite:moveTo(x1, animationStartPosition)
	
	local animationTimer = playdate.timer.new(400, animationStartPosition, animationEndPosition, playdate.easingFunctions.inQuad)
	
	animationTimer.updateCallback = function(timer)
		sprite:moveTo(x1, timer.value)
	end
	
	animationTimer.timerEndedCallback = function(timer)
		sprite:moveTo(x1, animationEndPosition)
		timer:remove()
	end
end

class("LevelComplete").extends(Widget)

function LevelComplete:init(config)
	self.levelDarkMode = config.levelDarkMode
	
	self:supply(Widget.kDeps.state)
	
	self.setStateInitial({
		inGame = 1,
		screen = 2
	}, 1)
	
	self.painters = {}
	self.images = {}
	self.blinkers = {}
end

function LevelComplete:_load()
	
	self.images.titleInGame = playdate.graphics.imageWithText("LEVEL COMPLETE", 200, 70):scaledImage(3)
	self.images.titleInGame:setInverted(self.levelDarkMode)

	self.blinkers.blinkerTitle = playdate.graphics.animation.blinker.new(300, 100)
	self.blinkers.blinkerTitle:startLoop()
	
	self.painters.background = Painter(function(rect)
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.fillRoundRect(rect.x, rect.y, rect.w, rect.h, 18)
		
		local insetRect = Rect.inset(rect, 4, 6)
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.fillRoundRect(insetRect.x, insetRect.y, insetRect.w, insetRect.h, 16)
		
		playdate.graphics.setColor(playdate.graphics.kColorClear)
		playdate.graphics.fillRoundRect(rect.x, rect.y, rect.w, rect.h, 18)
	end)
end

function LevelComplete:_draw(rect)
	self.painters.background:draw(rect)
	
	if self.blinkers.blinkerTitle.on then
		local imageRect = Rect.size(self.images.titleInGame:getSize())
		local imageRectCentered = Rect.center(imageRect, rect)
		self.images.titleInGame:draw(rect.x + imageRectCentered.x, rect.y + imageRectCentered.y)
	end
end

function LevelComplete:_update()
	
end
class("WidgetLevel").extends(Widget)

function WidgetLevel:init(config)
	self.filePathLevel = config.filePathLevel
	
	self:supply(Widget.kDeps.state)
	
	self:setStateInitial({
		stopped = 1,
		playing = 2,
	}, 1)
	
	self.sprites = {}
end

function WidgetLevel:_load()
	
	-- Periodic Blinker
	
	self.periodicBlinker = periodicBlinker({onDuration = 50, offDuration = 50, cycles = 8}, 300)
	
	-- Sprite Cycler
	
	local chunkLength = AppConfig["chunkLength"]
	local recycleSpriteIds = {"platform", "killBlock", "coin", "checkpoint"}
	
	self.spriteCycler = SpriteCycler(chunkLength, recycleSpriteIds, function(id, position, config, spriteToRecycle)
		local sprite = spriteToRecycle;
			
		if sprite == nil then
			-- Create sprites
			if id == "platform" then
				sprite = Platform.new()
			elseif id == "killBlock" then
				sprite = KillBlock.new(self.periodicBlinker)
			elseif id == "coin" then
				sprite = Coin.new()
			elseif id == "checkpoint" then
				sprite = Checkpoint.new()
			elseif id == "player" then
				sprite = Wheel.new()
				sprite:resetValues()
				sprite:setAwaitingInput()
				self.wheel = sprite
				
				if self.previousLoadPoint ~= nil then
					position = self.previousLoadPoint
				end
			elseif id == "levelEnd" then
				sprite = LevelEnd.new()
			else 
				print("Unrecognized ID: ".. id)
			end
		end
		
		if config ~= nil then
			sprite:loadConfig(config)
		end
		
		if position ~= nil then
			sprite:moveTo(kGame.gridSize * position.x, kGame.gridSize * position.y)
			sprite:add()
		end
		
		return sprite
	end)
	
	-- Load level file
	
	self.config = json.decodeFile(self.filePathLevel)
	
	assert(self.config)
	
	-- Load level into spritecycler
	
	self.spriteCycler:load(self.config)
	
	--
	
	self.spriteCycler:preloadSprites({
		id = "platform",
		count = 120
	}, {
		id = "killBlock",
		count = 40
	}, {
		id = "coin",
		count = 30
	}, {
		id = "checkpoint",
		count = 1
	})
	
	-- Load theme (Parallax BG)
	
	local themeId = self.config.theme
	
	if themeId ~= 0 then
		self.theme = kThemes[themeId]
	end
	
	if AppConfig.enableParalaxBackground and self.theme ~= nil then
		self.background = ParalaxBackground.new()
		self.background:loadTheme(self.theme)
		
		self.background:setParalaxDrawingRatios()
	end
	
	-- Add HUD
	
	if not self.spritesLoaded then
		self.spritesLoaded = true
		
		self.hud = Hud()
		self.hud:moveTo(3, 2)
	end
end

function WidgetLevel:_draw(rect)
	
end

function WidgetLevel:_update()
	
	local drawOffsetX, drawOffsetY = gfx.getDrawOffset()
	
	-- Update periodicBlinker
	
	self.periodicBlinker:update()
	
	-- Update background parallax based on current offset
	
	if AppConfig.enableParalaxBackground and self.theme ~= nil then
		self.background:setParalaxDrawOffset(drawOffsetX)
	end
	
	-- Updates sprites cycling
	self.spriteCycler:update(-drawOffsetX / kGame.gridSize, drawOffsetY / kGame.gridSize)
	
	if not self.isFinishedTransitioning then
		return
	end
	
	-- On game start
	
	if self.state == self.kStates.stopped then
		-- Awaiting player input (jump / crank)
		if playdate.buttonIsPressed(playdate.kButtonA) or (math.abs(playdate.getCrankChange()) > 5) then
			
			-- Start game
			
			self.wheel:startGame()
			
			self.levelTimer:start()
			
			self.gameState = gameStates.playing
		end
	end
	
	if self.state == self.kStates.playing then
		
		-- Update Blinker
		
		if blinker ~= nil then
			blinker:update()
			if levelCompleteSprite ~= nil then	
				levelCompleteSprite:setVisible(blinker.on)
			end
		end
		
		-- Touch Checkpoint: set new load point
		
		if self.wheel.hasTouchedNewCheckpoint == true then
			local position = self.wheel:getRecentCheckpoint()
			self.previousLoadPoint = { x = position.x / kGame.gridSize, y = position.y / kGame.gridSize }
		end
		
		local updatedCoinCount = self.wheel:getCoinCountUpdate()
		if updatedCoinCount > 0 then
			self.coinCount += updatedCoinCount
			self.hud:updateCoinCount(self.coinCount)
		end
		
		-- Level End Trigger
		
		if self.wheel.hasReachedLevelEnd and levelCompleteSprite == nil then
			
			self:onLevelComplete()
			
			self.levelTimer:pause()
		end
		
		-- Camera movement based on wheel position
		
		self:updateDrawOffset()
		
		-- Game State checking
		
		if self.wheel.hasJustDied then
			self.levelTimer:pause()
			
			self.gameState = gameStates.playerDied
		end
	end
	
	-- TODO: Level End
	if false then
		if self.state == self.kStates.levelEnd then
			if playdate.buttonJustPressed(playdate.kButtonA) then
				sceneManager:switchScene(scenes.menu, function() self:destroy() end)
			elseif playdate.buttonJustPressed(playdate.kButtonB) then
				self.previousLoadPoint = nil
				sceneManager:switchScene(scenes.game, function () end)
			end
		end
	end
end

function WidgetLevel:stateChanged(stateFrom, stateTo)
	if stateFrom == self.kStates.stopped and (stateTo == self.kStates.play) then
		
		-- Start periodicBlinker for flashing animations
		
		self.periodicBlinker:start()
		
		-- Set background drawing callback
		
		if AppConfig.enableParalaxBackground and self.theme ~= nil then
			local callback = self.background:getBackgroundDrawingCallback()
			
			gfx.sprite.setBackgroundDrawingCallback(callback)
			
			self.background:add()
		end
		
		-- Set game as ready to start
		
		self.gameState = gameStates.readyToStart
		
		-- Initialize sprite cycling using initial wheel position
		
		local initialChunk = self.spriteCycler:getFirstInstanceChunk("player")
		self.spriteCycler:loadInitialSprites(initialChunk, 1)
		
		-- Set camera to center on wheel
		
		self:updateDrawOffset()
		
		-- Play music
		
		if AppConfig.enableBackgroundMusic and self.theme ~= nil then
			local musicFilePath = getMusicFilepathForTheme(self.theme)
			self.filePlayer = FilePlayer(musicFilePath)
			
			self.filePlayer:play()
		end
		
		-- Set up level timer 
		
		self.hud:add()
		
		self.levelTimerCounter = 0
		self.coinCount = 0
		
		local levelTimer = playdate.timer.new(999000)
		levelTimer.updateCallback = function(timer)
			self.levelTimerCounter = timer.currentTime
			
			self.hud:updateTimer(self.levelTimerCounter)
		end
		levelTimer.timerEndedCallback = function()
			-- TODO: Trigger game over
			print("Game over!")
		end
		
		levelTimer:pause()
		
		self.levelTimer = levelTimer
	end
end


function WidgetLevel:updateDrawOffset()
	local drawOffset = gfx.getDrawOffset()
	local relativeX = self.wheel.x + drawOffset
	if relativeX > 150 then
		gfx.setDrawOffset(-self.wheel.x + 150, 0)
	elseif relativeX < 80 then
		gfx.setDrawOffset(-self.wheel.x + 80, 0)
	end
end

function WidgetLevel:onLevelComplete(nextLevel)

	addLevelCompleteSprite()
		
	timer.performAfterDelay(3000,
		function ()
			self.gameState = gameStates.levelEnd
			
			levelCompleteSprite:remove()
			levelCompleteSprite = nil
			
			local stars = 1
			
			local displayObjectiveCoins = self.config.objectives[1].coins
			local displayObjectiveTime = self.config.objectives[2].time
			
			for _, objective in pairs(self.config.objectives) do
				local objectiveReached = true
				
				if objective.coins ~= nil then
					objectiveReached = objectiveReached and self.coinCount >= objective.coins
				end
				
				if objective.time ~= nil then
					objectiveReached = objectiveReached and self.levelTimerCounter <= (objective.time * 1000)
				end
				
				if objectiveReached == true then
					stars += 1
				end
			end
			
			print("Got ".. stars.. " stars!")
			
			local stringTime = convertToTimeString(self.levelTimerCounter, 1)
			local stringTimeObjective = convertToTimeString(displayObjectiveTime * 1000, 1)
			drawLevelClearSprite(stars, self.coinCount, displayObjectiveCoins, stringTime, stringTimeObjective)
		end
	)
end

function addLevelCompleteSprite()
	levelCompleteSprite = sizedTextSprite("LEVEL COMPLETE", 3)
	
	levelCompleteSprite:setImage(levelCompleteSprite:getImage())
	levelCompleteSprite:setIgnoresDrawOffset(true)
	
	levelCompleteSprite:add()
	levelCompleteSprite:moveTo(10, 110)

	blinker = playdate.graphics.animation.blinker.new(300, 100)
	blinker:startLoop()
end

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
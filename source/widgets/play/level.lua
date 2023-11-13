class("WidgetLevel").extends(Widget)

function WidgetLevel:init(config)
	self.filePathLevel = config.filePathLevel
	
	self:supply(Widget.kDeps.state)
	
	self:setStateInitial(kPlayStates, 1)
	
	self.sprites = {}
	self.children = {}
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
	
	-- Add HUD
	
	if not self.spritesLoaded then
		self.spritesLoaded = true
		
		self.hud = Hud()
		self.hud:moveTo(3, 2)
	end
	
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

function WidgetLevel:_draw(rect)
	
	if self.state == self.kStates.stopped then
		if self.children.gameOver ~= nil then
			self.children.gameOver:draw(rect)
		end
	end
end

function WidgetLevel:_update()
	
	local drawOffsetX, drawOffsetY = gfx.getDrawOffset()
	
	-- Update periodicBlinker
	
	self.periodicBlinker:update()
	
	-- Updates sprites cycling
	self.spriteCycler:update(-drawOffsetX / kGame.gridSize, drawOffsetY / kGame.gridSize)
	
	-- On game start
	
	if self.state == self.kStates.start then
		-- Awaiting player input (jump / crank)
		if playdate.buttonIsPressed(playdate.kButtonA) or (math.abs(playdate.getCrankChange()) > 5) then
			-- Start game
			
			self.wheel:startGame()
			
			self.levelTimer:start()
			
			self:setState(self.kStates.playing)
		end
	end
	
	if self.state == self.kStates.playing then
		
		-- Update Blinker
		
		if blinker ~= nil then
			blinker:update()
			if self.levelCompleteSprite ~= nil then	
				self.levelCompleteSprite:setVisible(blinker.on)
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
		
		if self.wheel.hasReachedLevelEnd and self.levelCompleteSprite == nil then
			
			self:onLevelComplete()
			
			self.levelTimer:pause()
		end
		
		-- Camera movement based on wheel position
		
		self:updateDrawOffset()
		
		-- Game State checking
		
		if self.wheel.hasJustDied then
			self.levelTimer:pause()
			
			self:setState(self.kStates.stopped)
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
	
	if self.state == self.kStates.stopped then
		if playdate.buttonIsPressed(playdate.kButtonA) then
			self:setState(self.kStates.start)
		end
	end
end

function WidgetLevel:changeState(stateFrom, stateTo)
	if stateFrom == self.kStates.start and (stateTo == self.kStates.playing) then
		self.periodicBlinker:start()
	elseif stateFrom == self.kStates.playing and (stateTo == self.kStates.stopped) then
		
		if self.children.gameOver == nil then
			self.children.gameOver = Widget.new(WidgetGameOver)
			self.children.gameOver:load()
		end
		
		self.children.gameOver.sprite:add()
		
		self.spriteCycler:unloadAll()
		
		if AppConfig.enableBackgroundMusic and self.theme ~= nil then
			self.filePlayer:stop()
		end
		
		self.levelTimer:remove()
		self.hud:remove()
		
		self.periodicBlinker:stop()
		
		self.wheel:remove()
		
	elseif stateFrom == self.kStates.stopped and (stateTo == self.kStates.start) then
		self.children.gameOver.sprite:remove()
		
		self.periodicBlinker:start()
		
		-- Initialize sprite cycling using initial wheel position
		
		self.config = json.decodeFile(self.filePathLevel)
			
		self.spriteCycler:load(self.config)
		
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

function WidgetLevel:onLevelComplete()

	self:addLevelCompleteSprite()
		
	timer.performAfterDelay(3000,
		function ()
			self.levelCompleteSprite:remove()
			--self.levelCompleteSprite = nil
			
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

function WidgetLevel:addLevelCompleteSprite()
	self.levelCompleteSprite = sizedTextSprite("LEVEL COMPLETE", 3)
	
	self.levelCompleteSprite:setImage(self.levelCompleteSprite:getImage())
	self.levelCompleteSprite:setIgnoresDrawOffset(true)
	
	self.levelCompleteSprite:add()
	self.levelCompleteSprite:moveTo(10, 110)

	blinker = playdate.graphics.animation.blinker.new(300, 100)
	blinker:startLoop()
end

class("WidgetLevel").extends(Widget)

function WidgetLevel:init(config)
	self.config = config
	
	self:supply(Widget.kDeps.state)
	
	self:setStateInitial(kPlayStates, 1)
	
	self.sprites = {}
	self.children = {}
	self.signals = {}
end

function WidgetLevel:_load()
	
	-- Periodic Blinker
	
	self.periodicBlinker = periodicBlinker({onDuration = 50, offDuration = 50, cycles = 8}, 300)
	
	-- Wheel setup
	
	function setupSpriteWheel(wheel)
		self.wheel = wheel
		
		wheel.signals.onTouchCheckpoint = function()
			local position = self.wheel:getRecentCheckpoint()
			self.previousLoadPoint = { x = position.x / kGame.gridSize, y = position.y / kGame.gridSize }
		end
		
		wheel.signals.onDeath = function()
			self.signals.gameOver()
		end
		
		wheel.signals.onLevelComplete = function()
			if self.levelCompleteSprite ~= nil then
				return
			end
			
			self.levelTimer:pause()
			self.wheel.ignoresPlayerInput = true
			
			self.objectives = self:getLevelObjectives()
			
			self.signals.levelComplete()
		end
	end
	
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
				setupSpriteWheel(sprite)
				
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
	
	-- Load level into spritecycler
	
	self.spriteCycler:load(self.config.objects)
	
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
	
	-- Add HUD
	
	if not self.spritesLoaded then
		self.spritesLoaded = true
		
		-- TODO: Move HUD out of widget level into widget play
		self.hud = Hud()
		self.hud:moveTo(3, 2)
	end
	
	-- Initialize sprite cycling using initial wheel position
	
	local initialChunk = self.spriteCycler:getFirstInstanceChunk("player")
	self.spriteCycler:loadInitialSprites(initialChunk, 1)
	
	-- Set up level timer 
	
	self.hud:add()
	
	self.levelTimerCounter = 0
	self.coinCount = 0
	
	local levelTimer = playdate.timer.new(999000)
	levelTimer.updateCallback = function(timer)
		self.levelTimerCounter = timer.currentTime
		
		self.hud:updateTimer(self.levelTimerCounter)
	end
	
	levelTimer:pause()
	
	self.levelTimer = levelTimer
end

function WidgetLevel:_draw(rect)
	
end

function WidgetLevel:_update()
	
	-- Update periodicBlinker
	
	self.periodicBlinker:update()
	
	-- Updates sprites cycling
	
	self.spriteCycler:update(gfx.getDrawOffset())
	
	-- On game start
	
	if self.state == self.kStates.start then
		-- Awaiting player input (jump / crank)
		if playdate.buttonIsPressed(playdate.kButtonA) or (math.abs(playdate.getCrankChange()) > 5) then
			-- Start game
			
			self.wheel:startGame()
			
			self.levelTimer:start()
			
			self.signals.startPlaying()
		end
	end
	
	if self.state == self.kStates.playing then
		
		-- Touch Checkpoint: set new load point
		
		local updatedCoinCount = self.wheel:getCoinCountUpdate()
		if updatedCoinCount > 0 then
			self.coinCount += updatedCoinCount
			self.hud:updateCoinCount(self.coinCount)
		end
	end
	
	-- Update draw offset
	
	local drawOffset = gfx.getDrawOffset()
	local relativeX = self.wheel.x + drawOffset
	if relativeX > 150 then
		gfx.setDrawOffset(-self.wheel.x + 150, 0)
	elseif relativeX < 80 then
		gfx.setDrawOffset(-self.wheel.x + 80, 0)
	end
end

function WidgetLevel:changeState(stateFrom, stateTo)
	if stateFrom == self.kStates.start and (stateTo == self.kStates.playing) then
		self.periodicBlinker:start()
	elseif stateFrom == self.kStates.playing and (stateTo == self.kStates.gameOver) then
		self.spriteCycler:unloadAll()
		
		if AppConfig.enableBackgroundMusic and self.theme ~= nil then
			self.filePlayer:stop()
		end
		
		self.levelTimer:pause()
		self.hud:remove()
		
		self.periodicBlinker:stop()
		
		self.wheel:remove()	
	elseif stateFrom == self.kStates.playing and (stateTo == self.kStates.levelComplete) then
		
	elseif stateFrom == self.kStates.gameOver and (stateTo == self.kStates.playing) then
		self.periodicBlinker:start()
		
		-- Initialize sprite cycling using initial wheel position
		
		self.spriteCycler:load(self.config.objects)
		
		local initialChunk = self.spriteCycler:getFirstInstanceChunk("player")
		self.spriteCycler:loadInitialSprites(initialChunk, 1)
		
		self.hud:add()
		self.wheel:startGame()
		
		self.levelTimer:start()
	end
end

function WidgetLevel:getLevelObjectives()
	local stars = 1
	
	local coinCountObjective = self.config.objectives[1].coins
	local timeObjective = self.config.objectives[2].time
	
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
	
	local timeString = convertToTimeString(self.levelTimerCounter, 1)
	local timeStringObjective = convertToTimeString(timeObjective * 1000, 1)

	return {
		stars = stars,
		timeString = timeString,
		coinCount = self.coinCount,
		timeStringObjective = timeStringObjective,
		coinCountObjective = coinCountObjective
	}
end

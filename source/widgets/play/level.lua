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
	
	-- Initialize sprite cycling using initial wheel position
	
	local initialChunk = self.spriteCycler:getFirstInstanceChunk("player")
	self.spriteCycler:loadInitialSprites(initialChunk, 1)
	
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
			
			self.signals.startPlaying()
		end
	end
	
	if self.state == self.kStates.playing then
		local updatedCoinCount = self.wheel:getCoinCountUpdate()
		if updatedCoinCount > 0 then
			self.signals.collectCoin(updatedCoinCount)
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

		self.periodicBlinker:stop()
		
		self.wheel:remove()	
	elseif stateFrom == self.kStates.playing and (stateTo == self.kStates.levelComplete) then
		
	elseif stateFrom == self.kStates.gameOver and (stateTo == self.kStates.playing) then
		self.periodicBlinker:start()
		
		-- Initialize sprite cycling using initial wheel position
		
		self.spriteCycler:load(self.config.objects)
		
		local initialChunk = self.spriteCycler:getFirstInstanceChunk("player")
		self.spriteCycler:loadInitialSprites(initialChunk, 1)
		
		self.wheel:startGame()
	end
end

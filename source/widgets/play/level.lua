import "utils/screenShake"

class("WidgetLevel").extends(Widget)

function WidgetLevel:init(config)
	self.config = config
	
	self:supply(Widget.deps.state)
	
	self:setStateInitial({
		ready = 1,
		playing = 2,
		--frozen = 3,
		unloaded = 4
	}, 1)
	
	self.sprites = {}
	self.children = {}
	self.signals = {}
end

function WidgetLevel:_load()
	
	-- Periodic Blinker
	
	self.periodicBlinker = periodicBlinker({onDuration = 50, offDuration = 50, cycles = 8}, 300)
	self.periodicBlinker:start()
	
	-- Wheel setup
	
	function setupSpriteWheel(wheel)
		self.wheel = wheel
		
		wheel.signals.onTouchCheckpoint = function()
			local position = self.wheel:getRecentCheckpoint()
			self.previousLoadPoint = { x = position.x / kGame.gridSize, y = position.y / kGame.gridSize }
			
			self.spriteCycler:saveConfigWithIndex(self.loadIndex)
			
			self.loadIndex += 1
			
			self.signals.onCheckpoint()
		end
		
		wheel.signals.onDeath = function()
			screenShake(400, 13)
			
			self.signals.gameOver()
		end
		
		wheel.signals.onLevelComplete = function()
			self.signals.levelComplete()
		end
	end
	
	-- Sprite Cycler
	
	local chunkLength = AppConfig["chunkLength"]
	local recycleSpriteIds = {"platform", "killBlock", "coin", "checkpoint", "levelEnd"}
	
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
				if self.wheel == nil then
					sprite = Wheel.new()
				else
					sprite = self.wheel
				end
				
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
			
			sprite:setZIndex(kZIndex.level)
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
	self.spriteCycler:loadInitialSprites(initialChunk, 1, 0)
	
	--
	
	self.loadIndex = 1
	self:updateDrawOffset()
end

function WidgetLevel:_update()
	if self.state == self.kStates.unloaded then
		return
	end
	
	if self.state == self.kStates.ready then
		self:updateDrawOffset()
		
		if playdate.buttonIsPressed(playdate.kButtonA) or (math.abs(playdate.getCrankChange()) > 5) then
			self.signals.startPlaying()
		end
	end
	
	self.periodicBlinker:update()
	
	local drawOffsetX, drawOffsetY = playdate.graphics.getDrawOffset()
	self.spriteCycler:update(drawOffsetX, drawOffsetY, self.loadIndex)
	
	if self.state == self.kStates.playing then
		local updatedCoinCount = self.wheel:getCoinCountUpdate()
		
		if updatedCoinCount > 0 then
			self.signals.collectCoin(updatedCoinCount)
		end
		
		self:updateDrawOffset()
	end
end

function WidgetLevel:_changeState(stateFrom, stateTo)
	if stateFrom == self.kStates.ready and (stateTo == self.kStates.playing) then
		self.wheel.ignoresPlayerInput = false
	elseif stateFrom == self.kStates.playing and (stateTo == self.kStates.unloaded) then
		self.spriteCycler:unloadAll()

		self.periodicBlinker:stop()
		
		self.wheel:remove()
	elseif stateFrom == self.kStates.unloaded and (stateTo == self.kStates.ready) then
		
		self.periodicBlinker:start()
		
		-- Initialize sprite cycling using initial wheel position
		
		self.spriteCycler:load(self.config.objects)
		
		local initialChunk = self.spriteCycler:getFirstInstanceChunk("player")
		
		self.spriteCycler:loadInitialSprites(initialChunk, 1, self.loadIndex)
		
		self:updateDrawOffset()
	end
end

function WidgetLevel:updateDrawOffset()
	local drawOffset = playdate.graphics.getDrawOffset()
	local relativeX = self.wheel.x + drawOffset
	if relativeX > 150 then
		playdate.graphics.setDrawOffset(-self.wheel.x + 150, 0)
	elseif relativeX < 80 then
		playdate.graphics.setDrawOffset(-self.wheel.x + 80, 0)
	end
end

function WidgetLevel:_unload()
	self.spriteCycler:unloadAll()
	
	self.periodicBlinker:stop()
	
	self.wheel:remove()
end

import "utils/screenShake"

local gfx <const> = playdate.graphics

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
	
	function _setupWheelSpriteSignals(wheel)		
		wheel.signals.onTouchCheckpoint = function()
			local position = wheel:getRecentCheckpoint()
			self.previousLoadPoint = { x = position.x / kGame.gridSize, y = position.y / kGame.gridSize }
			self.wheel.position = self.previousLoadPoint
			
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
	
	self.resetWheel = function()
		self.wheel.sprite:resetValues()
		self.wheel.sprite:setAwaitingInput()
	end
	
	-- Sprite Cycler
	
	local chunkLength = AppConfig["chunkLength"]
	local recycleSpriteIds = {"platform", "killBlock", "coin", "checkpoint", "levelEnd"}
	
	self.spriteCycler = SpriteCycler(chunkLength, recycleSpriteIds, function(id, position, levelObject, config, spriteToRecycle)
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
				assert(self.wheel == nil)
				self.wheel = levelObject
				
				sprite = Wheel.new()
				_setupWheelSpriteSignals(sprite)
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
	
	self.levelObjects = LogicalSprite.loadObjects(self.config.objects)
	self.spriteCycler:load(self.levelObjects)
	
	self.configHandler = ConfigHandler({"coin", "checkpoint"})
	self.configHandler:load(self.levelObjects)
	
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
	
	self.resetWheel()
	self:updateDrawOffset(self.wheel.position.x)
end

function WidgetLevel:_update()
	if self.state == self.kStates.unloaded then
		return
	end
	
	if self.state == self.kStates.ready then
		self:updateDrawOffset(self.wheel.position.x * kGame.gridSize)
		
		if playdate.buttonIsPressed(playdate.kButtonA) or (math.abs(playdate.getCrankChange()) > 5) then
			self.signals.startPlaying()
		end
	end
	
	self.periodicBlinker:update()
	
	local drawOffsetX, drawOffsetY = gfx.getDrawOffset()
	self.spriteCycler:update(drawOffsetX, drawOffsetY, self.loadIndex)
	
	if self.state == self.kStates.playing then
		local updatedCoinCount = self.wheel.sprite:getCoinCountUpdate()
		
		if updatedCoinCount > 0 then
			self.signals.collectCoin(updatedCoinCount)
		end
		
		self:updateDrawOffset(self.wheel.sprite.x)
	end
end

function WidgetLevel:_changeState(stateFrom, stateTo)
	if stateFrom == self.kStates.ready and (stateTo == self.kStates.playing) then
		self.wheel.sprite.ignoresPlayerInput = false
	elseif stateFrom == self.kStates.playing and (stateTo == self.kStates.unloaded) then
		self.spriteCycler:unloadAll()

		self.periodicBlinker:stop()
		
		--self.wheel.sprite:remove()
	elseif stateFrom == self.kStates.unloaded and (stateTo == self.kStates.ready) then
		
		self.periodicBlinker:start()
		
		-- Initialize sprite cycling using initial wheel position
		
		local initialChunk = self.spriteCycler:getFirstInstanceChunk("player")
		
		self.spriteCycler:loadInitialSprites(initialChunk, 1, self.loadIndex)
		
		self.wheel.sprite:moveTo(self.wheel.position.x * kGame.gridSize, self.wheel.position.y * kGame.gridSize)
		self.resetWheel()
	end
end

function WidgetLevel:updateDrawOffset(x)
	local drawOffset = gfx.getDrawOffset()
	local relativeX = x + drawOffset
	if relativeX > 150 then
		gfx.setDrawOffset(-x + 150, 0)
	elseif relativeX < 80 then
		gfx.setDrawOffset(-x + 80, 0)
	end
end

function WidgetLevel:_unload()
	self.spriteCycler:unloadAll()
	
	self.periodicBlinker:stop()
	
	self.wheel.sprite:remove()
end

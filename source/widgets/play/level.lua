import "utils/screenShake"

local gfx <const> = playdate.graphics

class("WidgetLevel").extends(Widget)

function WidgetLevel:init(config)
	self.config = config
	
	self:supply(Widget.deps.state)
	
	self:setStateInitial({
		ready = 1,
		playing = 2,
		unloaded = 3,
		restartCheckpoint = 4,
		restartLevel = 5,
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
	
	self.spriteCycler = SpriteCycler(chunkLength, recycleSpriteIds)
	self.configHandler = ConfigHandler({"coin", "checkpoint"})
	
	LogicalSprite.setCreateSpriteFromIdCallback(function(id)
		if id == "platform" then
			return Platform.new()
		elseif id == "killBlock" then
			return KillBlock.new(self.periodicBlinker)
		elseif id == "coin" then
			return Coin.new()
		elseif id == "checkpoint" then
			return Checkpoint.new()
		elseif id == "player" then
			local sprite = Wheel.new()
			_setupWheelSpriteSignals(sprite)
			return sprite
		elseif id == "levelEnd" then
			return LevelEnd.new()
		else 
			print("Unrecognized ID: ".. id)
		end
	end)
	
	local _createSpriteFromId = LogicalSprite.createSpriteFromId
	
	LogicalSprite.setCreateSpriteCallback(function(levelObject, spriteToRecycle)
		assert(levelObject.sprite == nil, "Level object already has a sprite!")
		local sprite
		
		if spriteToRecycle == nil then
			sprite = _createSpriteFromId(levelObject.id)
			
			if levelObject.id == "player" then
				assert(self.wheel == nil)
				self.wheel = levelObject
			end
			
			sprite:setZIndex(kZIndex.level)
		else
			sprite = spriteToRecycle
		end
		
		local position = levelObject.position
		if position ~= nil then
			sprite:moveTo(kGame.gridSize * position.x, kGame.gridSize * position.y)
			sprite:add()
		end
		
		return sprite
	end)
	
	local _configHandler = self.configHandler
	local _discardConfig = self.configHandler.discardConfig
	
	LogicalSprite.setDiscardConfigCallback(function(levelObject, shouldDiscardAll)
		_discardConfig(_configHandler, levelObject, self.loadIndex, shouldDiscardAll)
	end)
	
	local _saveConfig = self.configHandler.saveConfig
	
	LogicalSprite.setSaveConfigCallback(function(levelObject)
		_saveConfig(_configHandler, levelObject, self.loadIndex)
	end)
	
	local _loadConfig = self.configHandler.loadConfig
	
	LogicalSprite.setLoadConfigCallback(function(levelObject)
		_loadConfig(_configHandler, levelObject, self.loadIndex)
	end)
	
	-- Load level into spritecycler
	
	self.levelObjects = LogicalSprite.loadObjects(self.config.objects)
	self.spriteCycler:load(self.levelObjects)
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
	
	self.loadIndex = 1
	
	local initialChunk = self.spriteCycler:getFirstInstanceChunk("player")
	self.spriteCycler:loadChunk(initialChunk, 0)
	
	--
	
	self.wheel.positionInitial = self.wheel.position 
	self.resetWheel()
	
	local _logicalPositionWheel = self.wheel.position
	local _gridSize = kGame.gridSize
	local _spriteWheel = self.wheel.sprite
	local _getDrawOffset = gfx.getDrawOffset
	local _setDrawOffset = gfx.setDrawOffset
	
	self.setNeutralDrawOffset = function()
		_setDrawOffset(-_logicalPositionWheel.x * _gridSize + 100, 0)
	end
	
	self.setMovingDrawOffset = function()
		local drawOffsetCurrent = _getDrawOffset()
		local drawOffsetTarget = -_spriteWheel.x + 100 - (_spriteWheel.velocityX * 10)	
		local newOffset = (drawOffsetCurrent - drawOffsetTarget) / 6
		_setDrawOffset(drawOffsetCurrent - newOffset, 0)
	end

	self:setNeutralDrawOffset()
end

function WidgetLevel:_update()
	if self.state == self.kStates.unloaded then
		return
	end
	
	if self.state == self.kStates.ready then
		self:setNeutralDrawOffset()
		
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
		
		self:setMovingDrawOffset()
	end
end

function WidgetLevel:_changeState(stateFrom, stateTo)
	if stateFrom == self.kStates.ready and (stateTo == self.kStates.playing) then
		self.wheel.sprite.ignoresPlayerInput = false
	elseif stateFrom == self.kStates.playing and (stateTo == self.kStates.unloaded) then
		self.periodicBlinker:stop()

		self.spriteCycler:unloadAll()
		
		self.spriteCycler:discardLoadConfig(false)
		self.loadIndex -= 1
	elseif stateFrom == self.kStates.unloaded and (stateTo == self.kStates.restartCheckpoint) then
		self.loadIndex += 1
	elseif stateFrom == self.kStates.unloaded and (stateTo == self.kStates.restartLevel) then
		self.spriteCycler:discardLoadConfig(true)
		self.loadIndex = 1
		self.previousLoadPoint = nil
		self.wheel.position = self.wheel.positionInitial
		self:setNeutralDrawOffset()
	elseif stateFrom == self.kStates.unloaded and (stateTo == self.kStates.nextLevel) then
		self.spriteCycler:discardLoadConfig(true)
		self.loadIndex = 1
		self.previousLoadPoint = nil
		
		self.wheel.sprite:remove()
		self.wheel.sprite = nil
		self.wheel = nil
		self.levelObjects = nil
		
		self.levelObjects = LogicalSprite.loadObjects(self.config.objects)
		self.spriteCycler:load(self.levelObjects)
		self.configHandler:load(self.levelObjects)
		
		local initialChunk = self.spriteCycler:getFirstInstanceChunk("player")
		self.spriteCycler:loadChunk(initialChunk, self.loadIndex)
		
		self.wheel.positionInitial = self.wheel.position 
		self.resetWheel()
		self:setNeutralDrawOffset()
	elseif (stateFrom == self.kStates.restartCheckpoint or (stateFrom == self.kStates.restartLevel)) and (stateTo == self.kStates.ready) then
		self.periodicBlinker:start()
		
		-- Initialize sprite cycling using initial wheel position
		
		local initialChunk = self.spriteCycler:getFirstInstanceChunk("player")
		
		self.spriteCycler:loadChunk(initialChunk, self.loadIndex)
		
		self.wheel.sprite:moveTo(self.wheel.position.x * kGame.gridSize, self.wheel.position.y * kGame.gridSize)
		self.resetWheel()
		self:setNeutralDrawOffset()
	end
end

function WidgetLevel:_unload()
	self.spriteCycler:unloadAll()
	self.periodicBlinker:stop()
	self.wheel.sprite:remove()
	
	for _, sprite in pairs(self.sprites) do sprite:remove() end
	self.sprites = nil
	
	for _, child in pairs(self.children) do child:unload() end
	self.children = nil
end

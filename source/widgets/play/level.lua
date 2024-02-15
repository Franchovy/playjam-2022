import "utils/screenShake"

local gfx <const> = playdate.graphics

local _gridSize <const> = kGame.gridSize
local _getDrawOffset <const> = gfx.getDrawOffset
local _setDrawOffset <const> = gfx.setDrawOffset
local _approach <const> = math.approach
local _abs <const> = math.abs
local _pow <const> = math.pow
local _sign <const> = math.sign

class("WidgetLevel").extends(Widget)

function WidgetLevel:_init()
	self:supply(Widget.deps.state)

	self:setStateInitial(1, {
		"frozen",
		"playing",
	})
	
	self.sprites = {}
	self.signals = {}
	
	self.isLevelLoaded = false
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
			
			self.signals.onCheckpoint({ x = position.x, y = position.y - 25})
		end
		
		wheel.signals.onDeath = function()
			screenShake(400, 13)
			
			self.signals.gameOver()
		end
		
		wheel.signals.onLevelComplete = function()
			self.signals.levelComplete()
		end
	end
	
	local _logicalPositionWheel = nil
	local _spriteWheel = nil
	
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
	
	-- Loading/Unloading
	
	self.resetWheel = function()
		self.wheel.sprite:resetValues()
		self.wheel.sprite:setAwaitingInput()
		_spriteWheel = self.wheel.sprite
		_logicalPositionWheel = self.wheel.position
		
		self.wheel.sprite:moveTo(self.wheel.position.x * kGame.gridSize, self.wheel.position.y * kGame.gridSize)
	end
	
	self.resetCheckpoints = function()
		self.spriteCycler:discardLoadConfig(true)
		self.loadIndex = 1
		self.previousLoadPoint = nil
		
		self.wheel.sprite:remove()
		self.wheel.sprite = nil
		self.wheel = nil
	end
	
	self.unloadLevel = function()
		self.spriteCycler:unloadAll()
		self.spriteCycler:discardLoadConfig(false)
		self.loadIndex -= 1
		
		self.isLevelLoaded = false
	end
	
	local _loadLevel = function()
		local initialChunk = self.spriteCycler:getFirstInstanceChunk("player")
		self.spriteCycler:loadChunk(initialChunk, 0)
		
		self.isLevelLoaded = true
	end
	
	self.loadCheckpoint = function()
		self.loadIndex += 1
		
		_loadLevel()
		
		self.resetWheel()
		self:setNeutralDrawOffset()
	end
	
	self.loadLevelRestart = function()
		self.wheel.position = self.wheel.positionInitial
		
		self.resetCheckpoints()
		
		_loadLevel()
		
		self.resetWheel()
		self:setNeutralDrawOffset()
	end
	
	self.loadNextLevel = function()
		self.resetCheckpoints()
		
		self.loadLevelObjects()
		
		_loadLevel()
		
		self.wheel.positionInitial = self.wheel.position 
		self.resetWheel()
		self:setNeutralDrawOffset()
	end
	
	-- Load level into spritecycler
	
	self.loadLevelObjects = function()
		self.levelObjects = LogicalSprite.loadObjects(self.config.objects)
		self.spriteCycler:load(self.levelObjects)
		self.configHandler:load(self.levelObjects)
	end
	
	self.loadLevelObjects()
	
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
	
	_loadLevel()
	
	--
	
	self.wheel.positionInitial = self.wheel.position 
	self.resetWheel()
	
	self.setNeutralDrawOffset = function()
		_setDrawOffset(-_logicalPositionWheel.x * _gridSize + 100, 0)
	end
	
	local _cameraVelocity = 12
	self.setMovingDrawOffset = function()
		local drawOffsetCurrentX, drawOffsetCurrentY = _getDrawOffset()
		
		local velocityOffset = _pow(_abs(_spriteWheel.velocityX), 2) * _sign(_spriteWheel.velocityX)
		
		if _abs(velocityOffset) > 10 then
			_cameraVelocity = _approach(_cameraVelocity, 6, 0.1)
		else 
			_cameraVelocity = _approach(_cameraVelocity, 12, 1.5)
		end
		
		if _spriteWheel.velocityX < 0 then
			velocityOffset *= 2
		end
		
		local drawOffsetTarget = -_spriteWheel.x + 100 - velocityOffset
		local newOffset = (drawOffsetCurrentX - drawOffsetTarget) / _cameraVelocity
		
		local cielY = 72
		local newOffsetY = 0
		if _spriteWheel.y < cielY then
			newOffsetY = (drawOffsetCurrentY + (cielY - _spriteWheel.y)) / 2
		else 
			newOffsetY = math.approach(0, drawOffsetCurrentY, 4)
		end

		_setDrawOffset(drawOffsetCurrentX - newOffset, newOffsetY)
	end

	self:setNeutralDrawOffset()
end

function WidgetLevel:_update()
	if self.isLevelLoaded == true then
		local drawOffsetX, drawOffsetY = gfx.getDrawOffset()
		self.spriteCycler:update(drawOffsetX, drawOffsetY, self.loadIndex)	
	end
	
	if self.state == self.kStates.playing then
		self.periodicBlinker:update()
		
		local updatedCoinCount = self.wheel.sprite:getCoinCountUpdate()
		
		if updatedCoinCount > 0 then
			self.signals.collectCoin(updatedCoinCount)
		end
		
		self:setMovingDrawOffset()
	end
end

function WidgetLevel:_changeState(stateFrom, stateTo)
	if stateFrom == self.kStates.frozen and (stateTo == self.kStates.playing) then
		self.wheel.sprite.ignoresPlayerInput = false
		self.periodicBlinker:start()
	elseif stateFrom == self.kStates.playing and stateTo == self.kStates.frozen then
		self.periodicBlinker:stop()
		self.wheel.sprite.ignoresPlayerInput = true
	end
end

function WidgetLevel:_unload()
	self.spriteCycler:unloadAll()
	self.spriteCycler = nil
	self.configHandler = nil
	
	self.periodicBlinker:stop()
	self.periodicBlinker = nil
	
	self.wheel.sprite:remove()
	
	for _, sprite in pairs(self.sprites) do sprite:remove() end
	self.sprites = nil
	
	for _, child in pairs(self.children) do child:unload() end
	self.children = nil
end

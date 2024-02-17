import "logicalSprite"

class("SpriteCycler").extends()

local gfx <const> = playdate.graphics
local _ceil <const> = math.ceil
local _range <const> = table.range
local _contains <const> = table.contains
local _insert <const> = table.insert
local _remove <const> = table.remove
local _removevalue <const> = table.removevalue
local _removekey <const> = table.removekey
local _create <const> = table.create
local _assert <const> = assert
local _pairs <const> = pairs
local _spriteRemove <const> = gfx.sprite.remove
local _loadConfig <const> = LogicalSprite.loadConfig
local _createSprite <const> = LogicalSprite.createSprite
local _saveConfig <const> = LogicalSprite.saveConfig

local generationConfig = { left = 1, right = 1 }

local _spritesToRecycle
local _spritesWithConfig
local _spritesPersisted
local _data

local function _loadChunk(self, chunk, shouldLoad)
	local _chunkData = _data[chunk]
	if _chunkData == nil then
		return
	end
	
	for _, object in _pairs(_chunkData) do
		if _spritesPersisted[object.id] ~= true or (object.sprite == nil) then
			--[[_assert(object.sprite == nil == shouldLoad, 
				"A chunk's sprite did not correspond to its loaded state. Are you trying to load/unload an already loaded/unloaded chunk?")]]
			
			local _objectPool = _spritesToRecycle[object.id]
			
			if shouldLoad then
				-- LOAD SPRITE
				local spriteToRecycle
				if _objectPool ~= nil then
					spriteToRecycle = _remove(_objectPool)
				end
				
				_createSprite(object, spriteToRecycle)
				_loadConfig(object)
			else
				-- UNLOAD SPRITE
				_saveConfig(object)
				
				local sprite = _removekey(object, "sprite")
				_spriteRemove(sprite)
				
				if _objectPool ~= nil then
					_insert(_objectPool, sprite)
				end
			end
		end
	end
end

function SpriteCycler:init(chunkLength, recycledSpriteIds)
	self.chunksLoaded = _create(16, 4)
	self.chunkLength = chunkLength
	
	self.spritesToRecycle = _create(0, #recycledSpriteIds)
	for _, spriteId in pairs(recycledSpriteIds) do
		self.spritesToRecycle[spriteId] = _create(32, 0)
	end
	
	self.spritesToIgnore = { ["platform"] = true }
	self.spritesWithConfig = { ["coin"] = true, ["checkpoint"] = true, ["platformCollision"] = true }
	self.spritesPersisted = { ["player"] = true }
	
	_spritesToRecycle = self.spritesToRecycle
	_spritesWithConfig = self.spritesWithConfig
	_spritesPersisted = self.spritesPersisted
end

-- Level Data

-- Returns the chunk where the first sprite with id is found. Useful for getting the starting chunk of a level.
function SpriteCycler:getFirstInstanceChunk(id)
	for k, chunk in pairs(self.data) do
		for _, object in pairs(chunk) do
			if object.id == id then
				return math.ceil(object.position.x / self.chunkLength)
			end
		end
	end
end

function SpriteCycler:hasLoadedInitialLevel()
	return self.data ~= nil
end

function SpriteCycler:load(levelObjects)
	-- Load chunks from level config
	
	local data = _create(16, 5)
	local _chunkLength = self.chunkLength
	
	for _, levelObject in pairs(levelObjects) do
		if self.spritesToIgnore[levelObject.id] then
			goto continue
		end
		
		-- Create chunk if needed
		local _chunkIndex = _ceil((levelObject.position.x) / _chunkLength)
		
		if data[_chunkIndex] == nil then
			data[_chunkIndex] = _create(60, 0)
			setmetatable(data[_chunkIndex], table.weakValuesMetatable)
		end
		
		-- Insert level object into chunk data
		_insert(data[_chunkIndex], levelObject)
		
		::continue::
	end
	
	self.data = data
	_data = self.data
end

function SpriteCycler:preloadSprites(...)
	local spriteIdCountPairs = {...}
	local _createSpriteFromId = LogicalSprite.createSpriteFromId
	local _spritesToRecycle = self.spritesToRecycle
	
	for _, v in pairs(spriteIdCountPairs) do
		local id = v.id
		local count = v.count
		
		for i=1,count do
			local sprite = _createSpriteFromId(id)
			
			_insert(_spritesToRecycle[id], sprite)
		end
	end
end

-- Lifecycle

function SpriteCycler:loadChunk(initialChunkX)
	assert(#self.chunksLoaded == 0, "Cannot initialize when already initialized!")
	self.chunksLoaded = table.range(initialChunkX - generationConfig.left, initialChunkX + generationConfig.right)
	
	-- load Sprites In Chunk If Needed
	
	for _, chunk in pairs(self.chunksLoaded) do
		_loadChunk(self, chunk, true)
	end
end

function SpriteCycler:update(drawOffsetX, drawOffsetY)
	-- Convert to grid coordinates
	local drawOffsetX, drawOffsetY = ((-drawOffsetX + 200) / kGame.gridSize), (drawOffsetY / kGame.gridSize)
	
	local currentChunk = _ceil(drawOffsetX / self.chunkLength)
	local chunksShouldLoad = _range(currentChunk - generationConfig.left, currentChunk + generationConfig.right)
	
	for _, chunk in pairs(chunksShouldLoad) do
		if not _contains(self.chunksLoaded, chunk) then
			_loadChunk(self, chunk, true)
			_insert(self.chunksLoaded, chunk)
		end
	end
	
	for _, chunk in pairs(self.chunksLoaded) do
		if not _contains(chunksShouldLoad, chunk) then
			_loadChunk(self, chunk, false)
			_removevalue(self.chunksLoaded, chunk)
		end
	end
end

function SpriteCycler:unloadAll()
	for _, chunk in pairs(self.chunksLoaded) do
		_loadChunk(self, chunk, false)
		_removevalue(self.chunksLoaded, chunk)
	end
end

function SpriteCycler:saveConfigWithIndex()
	local _saveConfig = LogicalSprite.saveConfig
	for _, chunk in pairs(self.chunksLoaded) do
		for _, object in pairs(self.data[chunk]) do
			_saveConfig(object)
		end
	end
end

function SpriteCycler:discardLoadConfig(discardAll)
	if loadIndexFinish == nil then
		loadIndexFinish = loadIndexStart
	end
	
	local _discardConfig = LogicalSprite.discardConfig
	for k, chunk in pairs(self.data) do
		for _, object in pairs(chunk) do
			_discardConfig(object, discardAll)
		end
	end
end
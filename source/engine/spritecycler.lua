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

local _spritesMultichunk
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
		local id = object.id
		local needsSprite = object.sprite == nil
		if _spritesPersisted[id] ~= true or needsSprite then
			--[[_assert(object.sprite == nil == shouldLoad, 
				"A chunk's sprite did not correspond to its loaded state. Are you trying to load/unload an already loaded/unloaded chunk?")--]]
			
			local _objectPool = _spritesToRecycle[id]
			
			local _multichunkData, _multichunkDataObject = _spritesMultichunk[id]
			if _multichunkData then
				_multichunkDataObject = _spritesMultichunk[id][object]
				_multichunkDataObject[chunk] = shouldLoad
			end
			
			if shouldLoad then
				-- LOAD SPRITE
				local spriteToRecycle
				if _objectPool ~= nil then
					spriteToRecycle = _remove(_objectPool)
				end
				
				if not _multichunkData or (_multichunkData ~= nil and needsSprite) then
					_createSprite(object, spriteToRecycle)
					_loadConfig(object)
				end
			elseif not needsSprite then
				if _multichunkData then
					-- Unload multichunk object if all chunks have been unloaded.
					
					for _, chunkLoaded in pairs(_multichunkDataObject) do
						if chunkLoaded then
							goto continue
						end
					end
				end
				
				-- UNLOAD SPRITE
				_saveConfig(object)
				
				local sprite = _removekey(object, "sprite")
				_spriteRemove(sprite)
				
				if _objectPool ~= nil then
					_insert(_objectPool, sprite)
				end
			end
		end
		::continue::
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
	self.spritesMultichunk = { ["platformCollision"] = _create(0, 30) }
	
	_spritesToRecycle = self.spritesToRecycle
	_spritesWithConfig = self.spritesWithConfig
	_spritesPersisted = self.spritesPersisted
	_spritesMultichunk = self.spritesMultichunk
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
		local id = levelObject.id
		
		if self.spritesToIgnore[id] then
			goto continue
		end
		
		-- Create chunk if needed
		local _chunkIndex = _ceil(levelObject.position.x / _chunkLength)
		
		local multichunkData = _spritesMultichunk[id]
		local endChunk
		if multichunkData then
			-- Add to any further chunks if needed
			local endPosition = levelObject.position.x + levelObject.config.w
			endChunk = _ceil(endPosition / _chunkLength)
			
			multichunkData[levelObject] = table.create(0, 3)
		else
			endChunk = _chunkIndex
		end
			
		for chunk=_chunkIndex,endChunk do
			if data[chunk] == nil then
				data[chunk] = _create(60, 0)
				setmetatable(data[chunk], table.weakValuesMetatable)
			end
			
			-- Insert level object into chunk data
			_insert(data[chunk], levelObject)
			
			-- Add level object reference and chunk data to multichunk data
			if multichunkData then
				multichunkData[levelObject][chunk] = false
			end
		end
		
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
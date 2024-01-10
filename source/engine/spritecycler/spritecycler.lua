class("SpriteCycler").extends()

import "sprites"
import "chunks"

local _ceil <const> = math.ceil
local _range <const> = table.range
local _contains <const> = table.contains
local _chunkLoader <const> = SpriteCycler.chunkLoader
local _insert <const> = table.insert
local _remove <const> = table.remove
local _removevalue <const> = table.removevalue

local generationConfig = { left = 1, right = 2 }

function SpriteCycler:init(chunkLength, recycledSpriteIds, createSpriteCallback)
	self.chunksLoaded = {}
	self.spritesToRecycle = {}
	self.chunkLength = chunkLength
	self.recycledSpriteIds = recycledSpriteIds
	self.createSpriteCallback = createSpriteCallback
	self.spritesWithConfig = { ["coin"] = true, ["checkpoint"] = true }
	self.spritesPersisted = { ["player"] = true }
end

-- Level Data

-- Returns the chunk where the first sprite with id is found. Useful for getting the starting chunk of a level.
function SpriteCycler:getFirstInstanceChunk(id)
	for k, chunk in pairs(self.data) do
		for _, object in pairs(chunk[1]) do
			if object.id == id then
				return k
			end
		end
	end
end

function SpriteCycler:hasLoadedInitialLevel()
	return self.data ~= nil
end

function SpriteCycler:load(objects)
	
	-- Load chunks from level config
	
	local chunksData = self:getChunksDataForLevel(objects, self.chunkLength)
	
	-- Create Empty chunks if needed
	
	self:fillEmptyChunks(chunksData)
	
	-- Load item IDs for recycling sprites
	for _, v in pairs(self.recycledSpriteIds) do
		self.spritesToRecycle[v] = {}
	end
	
	self.data = chunksData
end

function SpriteCycler:preloadSprites(...)
	local spriteIdCountPairs = {...}
	local _createSpriteCallback = self.createSpriteCallback
	local _spritesToRecycle = self.spritesToRecycle
	
	for _, v in pairs(spriteIdCountPairs) do
		local id = v.id
		local count = v.count
		
		for i=1,count do
			local sprite = _createSpriteCallback(id)
			
			_insert(_spritesToRecycle[id], sprite)
		end
	end
end

-- Lifecycle

function SpriteCycler:loadInitialSprites(initialChunkX, initialChunkY, loadIndex)
	assert(self.chunksToLoad == nil, "Cannot initialize when already initialized!")
	self.chunksLoaded = table.range(initialChunkX - generationConfig.left, initialChunkX + generationConfig.right)
	
	-- load Sprites In Chunk If Needed
	
	for _, chunk in pairs(self.chunksLoaded) do
		_chunkLoader(self, chunk, true, loadIndex)
	end
end

function SpriteCycler:update(drawOffsetX, drawOffsetY, loadIndex)
	-- Convert to grid coordinates
	local drawOffsetX, drawOffsetY = (-drawOffsetX / kGame.gridSize), (drawOffsetY / kGame.gridSize)
	
	local currentChunk = _ceil(drawOffsetX / self.chunkLength)
	local chunksShouldLoad = _range(currentChunk - generationConfig.left, currentChunk + generationConfig.right)
	
	for _, chunk in pairs(chunksShouldLoad) do
		if not _contains(self.chunksLoaded, chunk) then
			_chunkLoader(self, chunk, true, loadIndex)
			_insert(self.chunksLoaded, chunk)
		end
	end
	
	for _, chunk in pairs(self.chunksLoaded) do
		if not _contains(chunksShouldLoad, chunk) then
			_chunkLoader(self, chunk, false, loadIndex)
			_removevalue(self.chunksLoaded, chunk)
		end
	end
end

function SpriteCycler:unloadAll()
	for _, chunk in pairs(self.chunksLoaded) do
		_chunkLoader(self, chunk, false, loadIndex)
		_removevalue(self.chunksLoaded, chunk)
	end
end

function SpriteCycler:saveConfigWithIndex(loadIndex)
	print("Saving with load index: ".. loadIndex)
	local count = 0
	for _, chunk in pairs(self.chunksLoaded) do
		for _, object in pairs(self.data[chunk][1]) do
			if object.sprite ~= nil and (self.spritesWithConfig[object.id] == true) then
				local sprite = object.sprite

				if object.config[loadIndex] == nil then
					object.config[loadIndex] = table.create(4, 0)
				end

				sprite:writeConfig(object.config[loadIndex])
									
				count += 1
			end
		end
	end
	
	print("Saved config for ".. count.. " sprites.")
end

function SpriteCycler:discardConfigForIndexes(loadIndexes)
	for _, i in pairs(loadIndexes) do
		for k, chunk in pairs(self.data) do
			for _, object in pairs(chunk[1]) do
				if object.config[i] ~= nil then
					for k, _ in pairs(object.config[i]) do 
						object.config[i].k = nil
					end
				end
			end
		end
	end
end
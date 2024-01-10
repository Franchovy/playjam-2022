class("SpriteCycler").extends()

import "sprites"
import "chunks"

local generationConfig = { left = 1, right = 2}

function SpriteCycler:init(chunkLength, recycledSpriteIds, createSpriteCallback)
	self.chunksLoaded = {}
	self.spritesToRecycle = {}
	self.chunkLength = chunkLength
	self.recycledSpriteIds = recycledSpriteIds
	self.createSpriteCallback = createSpriteCallback
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
	for _, v in pairs(spriteIdCountPairs) do
		local id = v.id
		local count = v.count
		
		for i=1,count do
			self:createRecycledSprite(id)
		end
	end
end

-- Lifecycle

function SpriteCycler:loadInitialSprites(initialChunkX, initialChunkY, loadIndex)
	local chunksToLoad = self:chunksToGenerate(initialChunkX, generationConfig)
	
	-- load Sprites In Chunk If Needed
	
	local _, _ = self:loadSpritesInChunksIfNeeded(chunksToLoad, loadIndex)
	self.chunksLoaded = chunksToLoad
end

function SpriteCycler:update(drawOffsetX, drawOffsetY, loadIndex)
	-- Convert to grid coordinates
	local drawOffsetX, drawOffsetY = (-drawOffsetX / kGame.gridSize), (drawOffsetY / kGame.gridSize)
	
	--
	
	local currentChunk = math.ceil(drawOffsetX / self.chunkLength) 
	local chunksShouldLoad = self:chunksToGenerate(currentChunk, generationConfig)
	
	-- Get chunks to unload
	
	local chunksToLoad = {}
	for _, chunk in pairs(chunksShouldLoad) do
		if self:chunkExists(chunk, 1) and not table.contains(self.chunksLoaded, chunk) then
			table.insert(chunksToLoad, chunk)
		end
	end
	local chunksToUnload = {}
	for _, chunk in pairs(self.chunksLoaded) do
		if self:chunkExists(chunk, 1) and not table.contains(chunksShouldLoad, chunk) then
			table.insert(chunksToUnload, chunk)
		end
	end
	
	if (#chunksToLoad > 0) or (#chunksToUnload > 0) then
		-- Load and Unload
		
		print("Loading chunks: ")
		printTable(chunksToLoad)
		
		print("Unloading chunks: ")
		printTable(chunksToUnload)
		
		local spritesUnloadedCount = self:unloadSpritesInChunksIfNeeded(chunksToUnload, loadIndex)
		local spritesLoadedCount, spritesRecycledCount = self:loadSpritesInChunksIfNeeded(chunksToLoad, loadIndex)
		
		print(spritesUnloadedCount.." sprites were unloaded.")
		print(spritesLoadedCount.." sprites were loaded, ".. spritesRecycledCount.. " of which were recycled.")
		
		--print("Data objects: ".. #self.data.objects)
		--print("Available recycled sprites: ".. #self.spritesToRecycle)
	end
end

function SpriteCycler:unloadAll()
	local count = self:unloadSpritesInChunksIfNeeded(self.chunksLoaded, nil)
	print("Unloaded ".. count.. " sprites from level.")
end

function SpriteCycler:saveConfigWithIndex(loadIndex)
	local count = 0
	for _, chunk in pairs(self.chunksLoaded) do
		if self:chunkExists(chunk, 1) then
			for _, object in pairs(self.data[chunk][1]) do
				if object.sprite ~= nil then
					local sprite = object.sprite

					if object.config[loadIndex] == nil then
						object.config[loadIndex] = {}
					end

					sprite:writeConfig(object.config[loadIndex])
										
					count += 1
				end
			end
		end
	end
	
	print("Saved config for ".. count.. " sprites.")
end

function SpriteCycler:discardConfigForIndexes(loadIndexes)
	for _, i in pairs(loadIndexes) do
		print("Discarding index: ".. i)
		
		for k, chunk in pairs(self.data) do
			for _, object in pairs(chunk[1]) do
				object.config[i] = nil
			end
		end
	end
end
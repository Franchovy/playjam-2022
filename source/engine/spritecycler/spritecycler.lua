import "sprites"
import "chunks"

class("SpriteCycler").extends()

local generationConfig = { left = 1, right = 2}

function SpriteCycler:init()
	self.data = {}
	self.chunksLoaded = {}
	self.spritesToRecycle = {}
end

function SpriteCycler:setData(levelConfig, chunkLength, recycledSpriteIds)
	self.chunkLength = chunkLength
	self.levelConfig = levelConfig
	self.recycledSpriteIds = recycledSpriteIds
end

function SpriteCycler:load()
	
	if self.initialData == nil then
		-- Load chunks from level config
		
		local chunksData = getChunksDataForLevel(self.levelConfig.objects, self.chunkLength)
		
		-- Create Empty chunks if needed
		
		fillEmptyChunks(chunksData)
		
		-- Load item IDs for recycling sprites
		for _, v in pairs(self.recycledSpriteIds) do
			self.spritesToRecycle[v] = {}
		end
		
		self.initialData = chunksData
	end
	
	-- Load level from initial data
	self.data = table.deepcopy(self.initialData)
end

function SpriteCycler:initialize(x, y)
	local currentChunk = math.ceil(x / self.chunkLength)
	local chunksToLoad = chunksToGenerate(currentChunk, generationConfig)
	
	-- load Sprites In Chunk If Needed
	
	local count, recycledCount = loadSpritesInChunksIfNeeded(self, chunksToLoad)
	print("Initialized level with ".. count.. " sprites, ".. recycledCount.. " of which were recycled.")
	self.chunksLoaded = chunksToLoad
end

function SpriteCycler:update(drawOffsetX, drawOffsetY)
	local currentChunk = math.ceil(drawOffsetX / self.chunkLength) 
	local chunksShouldLoad = chunksToGenerate(currentChunk, generationConfig)
	
	-- Get chunks to unload
	
	local chunksToLoad = {}
	for _, chunk in pairs(chunksShouldLoad) do
		if chunkExists(self, chunk, 1) and not table.contains(self.chunksLoaded, chunk) then
			table.insert(chunksToLoad, chunk)
		end
	end
	
	local chunksToUnload = {}
	for _, chunk in pairs(self.chunksLoaded) do
		if chunkExists(self, chunk, 1) and not table.contains(chunksShouldLoad, chunk) then
			table.insert(chunksToUnload, chunk)
		end
	end
	
	if (#chunksToLoad > 0) or (#chunksToUnload > 0) then
		-- Load and Unload
		
		local unloadCount = unloadSpritesInChunksIfNeeded(self, chunksToUnload)
		print("Sprites unloaded: ".. unloadCount)
		
		local loadCount, recycledCount = loadSpritesInChunksIfNeeded(self, chunksToLoad)
		print("Sprites loaded: ".. loadCount.. " of which ".. recycledCount.. " recycled.")
		
		printTable(self.chunksLoaded)
	end
end

function SpriteCycler:unloadAll()
	local count = unloadSpritesInChunksIfNeeded(self, self.chunksLoaded)
	print("Unloaded ".. count.. " sprites from level.")
	self.chunksLoaded = {}
end

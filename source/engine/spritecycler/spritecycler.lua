import "sprites"
import "chunks"

class("SpriteCycler").extends()

local generationRangeX = 2
local generationRangeY = 1

function SpriteCycler:init()
	self.data = {}
	self.chunksLoaded = {}
	self.spritesToRecycle = {}
end

function SpriteCycler:load(levelConfig, chunkLength, recycledSpriteIds)
	self.chunkLength = chunkLength
	
	-- Load chunks from level config
	
	local chunksData = getChunksDataForLevel(levelConfig.objects, chunkLength)
	
	-- Create Empty chunks if needed
	
	fillEmptyChunks(chunksData)
	
	-- Load item IDs for recycling sprites
	for _, v in pairs(recycledSpriteIds) do
		self.spritesToRecycle[v] = {}
	end
	
	self.data = chunksData
end

function SpriteCycler:initialize(x, y)
	local currentChunk = math.ceil(x / self.chunkLength)
	local chunksToLoad = {currentChunk}
	
	-- load Sprites In Chunk If Needed
	
	local count = loadSpritesInChunksIfNeeded(self, chunksToLoad)
	print("Initialized level with ".. count.. " sprites")
	self.chunksLoaded = chunksToLoad
end

function SpriteCycler:update(drawOffsetX, drawOffsetY)
	local currentChunk = math.ceil(drawOffsetX / self.chunkLength) 
	local chunksShouldLoad = {currentChunk - 1, currentChunk, currentChunk + 1}
	
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
		
		local loadCount = loadSpritesInChunksIfNeeded(self, chunksToLoad)
		print("Sprites loaded: ".. loadCount)
		
		local unloadCount = unloadSpritesInChunksIfNeeded(self, chunksToUnload)
		print("Sprites unloaded: ".. unloadCount)
		
		printTable(self.chunksLoaded)
	end
end

function SpriteCycler:unloadAll()
	local count = unloadSpritesInChunksIfNeeded(self, self.chunksLoaded)
	print("Unloaded ".. count.. " sprites from level.")
	self.chunksLoaded = {}
end

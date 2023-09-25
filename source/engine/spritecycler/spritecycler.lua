import "sprites"

class("SpriteCycler").extends()

local generationRangeX = 2
local generationRangeY = 1

function SpriteCycler:init(chunkLength)
	self.chunkLength = chunkLength
	self.data = {}
	self.chunksLoaded = {}
end

function SpriteCycler:load(config)
	local chunksData = getChunksDataForLevel(config.objects, self.chunkLength)
	
	self.data = chunksData
end

function getChunksDataForLevel(objects, chunkLength)
	local chunksData = {}
	
	for _, object in pairs(objects) do
		-- Create Chunk in level chunks
		chunkIndexX = math.ceil((object.position.x) / chunkLength)
		chunkIndexY = math.ceil((object.position.y + 1) / chunkLength)
		
		-- Create chunk if needed
		table.setIfNil(chunksData, chunkIndexX)
		table.setIfNil(chunksData[chunkIndexX], chunkIndexY)
		
		-- Insert object data
		local spriteData = spritePositionData(object)
		table.insert(chunksData[chunkIndexX][chunkIndexY], spriteData)
	end
	
	-- Create Empty chunks if needed
	
	fillEmptyChunks(chunksData)
	
	return chunksData
end

function fillEmptyChunks(chunksData)
	local chunkIndexesX = {}
	local chunkIndexesY = {}
	
	for chunkIndexX, v in pairs(chunksData) do
		table.insert(chunkIndexesX, chunkIndexX)
		
		for chunkIndexY, _ in pairs(chunksData[chunkIndexX]) do
			table.insert(chunkIndexesY, chunkIndexY)
		end
	end	
	
	local chunkIndexMinX = math.min(table.unpack(chunkIndexesX))
	local chunkIndexMaxX = math.max(table.unpack(chunkIndexesX))
	local chunkIndexMinY = math.min(table.unpack(chunkIndexesY))
	local chunkIndexMaxY = math.max(table.unpack(chunkIndexesY))
	
	for i=chunkIndexMinX, chunkIndexMaxX do
		table.setIfNil(chunksData, chunkIndexX)
		
		for j=chunkIndexMinX, chunkIndexMaxX do
			table.setIfNil(chunksData[chunkIndexX], chunkIndexY)
		end
	end
end

function SpriteCycler:update(drawOffsetX, drawOffsetY)
	--print("Draw offset: ".. drawOffsetX)
	local currentChunk = math.ceil(drawOffsetX / self.chunkLength) 
	local chunksShouldLoad = {currentChunk - 1, currentChunk, currentChunk + 1}
	
	--printTable(chunksShouldLoad)
	
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
	
	if (#chunksToLoad == 0) and (#chunksToUnload == 0) then
		return
	end
	
	print("Chunks Should load:")
	printTable(chunksShouldLoad)
	
	if (#chunksToLoad > 0) then
		print("Loading chunks: ")
		printTable(chunksToLoad)
	end
	
	if (#chunksToUnload > 0) then
		print("Unloading chunks: ")
		printTable(chunksToUnload)
	end
	
	-- Load and Unload
	
	local loadCount = loadChunksIfNeeded(self, chunksToLoad)
	print("Sprites loaded: ".. loadCount)
	
	local unloadCount = unloadChunksIfNeeded(self, chunksToUnload)
	print("Sprites unloaded: ".. unloadCount)
	
	printTable(self.chunksLoaded)
end

function SpriteCycler:initialize(x, y)
	local currentChunk = math.ceil(x / self.chunkLength)
	local chunksToLoad = {currentChunk}
	
	-- load Sprites In Chunk If Needed
	
	local count = loadChunksIfNeeded(self, chunksToLoad)
	print("Initialized level with ".. count.. " sprites")
	self.chunksLoaded = chunksToLoad
end

function SpriteCycler:unloadAll()
	local count = unloadChunksIfNeeded(self, self.chunksLoaded)
	print("Unloaded ".. count.. " sprites from level.")
	self.chunksLoaded = {}
end

function spritePositionData(object)
	return {
		id = object.id,
		position = {
			x = object.position.x,
			y = object.position.y,
		},
		config = object.config,
		isActive = false,
		sprite = nil
	}
end

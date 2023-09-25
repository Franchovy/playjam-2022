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
	print("Draw offset: ".. drawOffsetX)
	local currentChunk = math.ceil(drawOffsetX / self.chunkLength) 
	local chunksShouldLoad = {currentChunk, currentChunk + 1}
	
	printTable(chunksShouldLoad)
	
	-- Get chunks to unload
	
	local chunksToLoad = {}
	for _, v in pairs(chunksShouldLoad) do
		if not table.contains(self.chunksLoaded, v) then
			table.insert(chunksToLoad, v)
		end
	end
	
	local chunksToUnload = {}
	for _, v in pairs(self.chunksLoaded) do
		if not table.contains(chunksShouldLoad, v) then
			table.insert(chunksToUnload, v)
		end
	end
	
	if (#chunksToLoad == 0) and (#chunksToUnload == 0) then
		return
	end
	
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
end

function SpriteCycler:unloadAll()
	local count = unloadChunksIfNeeded(self, self.chunksLoaded)
	
	print("Unloaded ".. count.. " sprites from level.")
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


class("SpriteCycler").extends()

local generationRangeX = 2
local generationRangeY = 1

function SpriteCycler:init(chunkLength)
	self.chunkLength = chunkLength
	self.data = {}
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


function SpriteCycler:initializeChunks(chunks, createSpriteCallback)
	for _, chunk in pairs(chunks) do
		for _, object in pairs(self.data[chunk].sprites) do
			object.sprite = createSpriteCallback(object.id, object.position, object.config)
		end
		
		self.data[chunk].state = "loaded"
	end
end

function SpriteCycler:activateChunks(chunks, activateSpriteCallback)
	for _, chunk in pairs(chunks) do
		if self.data[chunk] ~= nil and self.data[chunk].state == "loaded" then
			for _, object in pairs(self.data[chunk].sprites) do
				if not object.isActive then
					activateSpriteCallback(object.sprite)
					object.isActive = true
				end
			end
			
			self.data[chunk].state = "active"
		end
	end
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

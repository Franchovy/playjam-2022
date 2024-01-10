
function SpriteCycler:chunkExists(x, y)
	return (self.data[x] ~= nil) and (self.data[x][y] ~= nil)
end

function SpriteCycler:getChunksDataForLevel(objects, chunkLength)
	local chunksData = {}
	
	for _, object in pairs(objects) do
		-- Create Chunk in level chunks
		chunkIndexX = math.ceil((object.position.x) / chunkLength)
		chunkIndexY = math.ceil((object.position.y + 1) / chunkLength)
		
		-- Create chunk if needed
		table.setIfNil(chunksData, chunkIndexX)
		table.setIfNil(chunksData[chunkIndexX], chunkIndexY)
		
		-- Insert object data
		local spriteData = self:spritePositionData(object)
		table.insert(chunksData[chunkIndexX][chunkIndexY], spriteData)
	end
	
	return chunksData
end

function SpriteCycler:fillEmptyChunks(chunksData)
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

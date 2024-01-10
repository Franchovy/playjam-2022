

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

function loadChunksIfNeeded(self, chunksToLoad)
	local count = 0
	
	for _, chunk in pairs(chunksToLoad) do
		if not table.contains(self.chunksLoaded, chunk) then
			-- Load chunk
			local chunkData = self.data[chunk][1]
			
			for _, object in pairs(chunkData) do
				object.sprite = self.createSpriteCallback(object.id, object.position, object.config, nil)
				
				count += 1
			end
			
			table.insert(self.chunksLoaded, chunk)
		end
	end
	
	return count
end


function unloadChunksIfNeeded(self, chunksToUnload)
	local count = 0
	
	for _, chunk in pairs(chunksToUnload) do
		if table.contains(self.chunksLoaded, chunk) then		
			local chunkData = self.data[chunk][1]
			
			for _, object in pairs(chunkData) do
				object.sprite:remove()
				object.sprite = nil
				
				count += 1
			end
			
			table.remove(self.chunksLoaded, chunk)
		end
	end
	
	return count
end
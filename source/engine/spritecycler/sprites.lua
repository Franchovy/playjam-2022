import "extensions"
import "chunks"

function spritePositionData(object)
	local spriteData = {
		id = object.id,
		position = {
			x = object.position.x,
			y = object.position.y,
		},
		config = object.config,
		isActive = false,
		sprite = nil
	}
	
	return spriteData
end

function loadSpritesInChunksIfNeeded(self, chunksToLoad)
	local count = 0
	local recycledSpriteCount = 0
	
	for _, chunk in pairs(chunksToLoad) do
		if chunkExists(self, chunk, 1) and not table.contains(self.chunksLoaded, chunk) then
			-- Load chunk
			local chunkData = self.data[chunk][1]
			
			for _, object in pairs(chunkData) do
				local spriteToRecycle = getRecycledSprite(self, object.id)
				object.sprite = self.createSpriteCallback(object.id, object.position, object.config, spriteToRecycle)
				
				count += 1
				
				if spriteToRecycle ~= nil then
					recycledSpriteCount += 1
				end
			end
			
			table.insert(self.chunksLoaded, chunk)
		end
	end
	
	return count, recycledSpriteCount
end

function unloadSpritesInChunksIfNeeded(self, chunksToUnload)
	local count = 0
	
	for _, chunk in pairs(chunksToUnload) do
		if chunkExists(self, chunk, 1) and table.contains(self.chunksLoaded, chunk) then
			local chunkData = self.data[chunk][1]
			
			for _, object in pairs(chunkData) do
				local shouldRecycle = true
				if self.spritesToRecycle[object.id] == nil then
					-- sprite is not registered as recyclable
					shouldRecycle = false
				end
				
				if shouldRecycle and object.sprite ~= nil then
					local sprite = table.removekey(object, "sprite")
					
					sprite:updateConfig(object.config)
					sprite:remove()
					
					recycleSprite(self, sprite, object.id)
					
					count += 1
				end
			end
			
			table.removevalue(self.chunksLoaded, chunk)
		end
	end
	
	return count
end

function getRecycledSprite(self, id) 
	if self.spritesToRecycle[id] == nil then
		-- sprite is not registered as recyclable
		return nil
	end
	
	if #self.spritesToRecycle[id] == 0 then
		-- No sprites to recycle
		return nil
	end
	
	local sprite = table.remove(self.spritesToRecycle[id])
	return sprite
end

function recycleSprite(self, sprite, id)
	if self.spritesToRecycle[id] == nil then
		-- sprite is not registered for recycling
		return
	end
	
	table.insert(self.spritesToRecycle[id], sprite)
end

function debugPrintRecycledSprites(self)
	local printContents = {}
	for k, v in pairs(self.spritesToRecycle) do
		printContents[k] = #v
	end
	print("Sprites Recycled:")
	printTable(printContents)
end

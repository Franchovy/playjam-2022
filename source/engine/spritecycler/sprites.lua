import "extensions"
import "chunks"

function SpriteCycler:spritePositionData(object)
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

function SpriteCycler:loadSpritesInChunksIfNeeded(chunksToLoad, loadIndex)
	local count = 0
	local recycledSpriteCount = 0
	
	for _, chunk in pairs(chunksToLoad) do
		if self:chunkExists(chunk, 1) and not table.contains(self.chunksLoaded, chunk) then
			-- Load chunk
			local chunkData = self.data[chunk][1]
			
			for _, object in pairs(chunkData) do
				if self.spritesToRecycle[object.id] ~= nil or object.sprite == nil then
					local spriteToRecycle = self:getRecycledSprite(object.id)
					
					local config = self:getIndexedConfig(object.config, loadIndex)
					object.sprite = self.createSpriteCallback(object.id, object.position, config, spriteToRecycle)
					
					count += 1
					
					if spriteToRecycle ~= nil then
						recycledSpriteCount += 1
					end
				end
			end
			
			table.insert(self.chunksLoaded, chunk)
		end
	end
	
	return count, recycledSpriteCount
end

function SpriteCycler:unloadSpritesInChunksIfNeeded(chunksToUnload, loadIndex)
	local count = 0
	
	for _, chunk in pairs(chunksToUnload) do
		if self:chunkExists(chunk, 1) and table.contains(self.chunksLoaded, chunk) then
			local chunkData = self.data[chunk][1]
			
			for _, object in pairs(chunkData) do
				local shouldRecycle = true
				if self.spritesToRecycle[object.id] == nil then
					-- sprite is not registered as recyclable
					shouldRecycle = false
				end
				
				if shouldRecycle and object.sprite ~= nil then
					local sprite = table.removekey(object, "sprite")
					
					-- Save the active config to the active load index. Else, discard the active config.
					if loadIndex ~= nil then
						if object.config[loadIndex] == nil then
							object.config[loadIndex] = {}
						end
						
						sprite:writeConfig(object.config[loadIndex])
					end
					
					sprite:remove()
					
					self:recycleSprite(sprite, object.id)
					
					count += 1
				end
			end
			
			table.removevalue(self.chunksLoaded, chunk)
		end
	end
	
	return count
end

function SpriteCycler:createRecycledSprite(id)
	local sprite = self.createSpriteCallback(id)
	
	table.insert(self.spritesToRecycle[id], sprite)
end

function SpriteCycler:getRecycledSprite(id) 
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

function SpriteCycler:recycleSprite(sprite, id)
	if self.spritesToRecycle[id] == nil then
		-- sprite is not registered for recycling
		return
	end
	
	table.insert(self.spritesToRecycle[id], sprite)
end

function SpriteCycler:debugPrintRecycledSprites()
	local printContents = {}
	for k, v in pairs(self.spritesToRecycle) do
		printContents[k] = #v
	end
	print("Sprites Recycled:")
	printTable(printContents)
end

function SpriteCycler:getIndexedConfig(config, loadIndex)
	for i=loadIndex, 0, -1 do
		if config[i] ~= nil then
			return config[i]
		end
	end
end

import "extensions"
import "chunks"

local _removekey = table.removekey

local function _getIndexedConfig(config, loadIndex)
	for i=loadIndex, 0, -1 do
		if config[i] ~= nil then
			return config[i]
		end
	end
end

function SpriteCycler:chunkLoader(chunk, shouldLoad, loadIndex)
	local _chunkData = self.data[chunk]
	if _chunkData == nil then
		return
	end
	
	local _spritesToRecycle = self.spritesToRecycle
	local _spritesWithConfig = self.spritesWithConfig
	local _createSpriteCallback = self.createSpriteCallback
	local _recycleSprite = self.recycleSprite
	local _spritesPersisted = self.spritesPersisted
	
	for _, object in pairs(_chunkData) do
		if _spritesPersisted[object.id] ~= true or (object.sprite == nil) then
			assert(object.sprite == nil == shouldLoad, 
				"A chunk's sprite did not correspond to its loaded state. Are you trying to load/unload an already loaded/unloaded chunk?")
			
			if shouldLoad then
				-- LOAD SPRITE
				local spriteToRecycle
				if _spritesToRecycle[object.id] ~= nil then
					spriteToRecycle = table.remove(_spritesToRecycle[object.id])
				end
				
				local config
				if _spritesWithConfig[object.id] == true then
					config = _getIndexedConfig(object.config, loadIndex)
				end
				
				object.sprite = _createSpriteCallback(object.id, object.position, config, spriteToRecycle)
			else
				-- UNLOAD SPRITE
				local sprite = _removekey(object, "sprite")
				
				-- Save the active config to the active load index. Else, discard the active config.
				if _spritesWithConfig[object.id] == true and (loadIndex ~= nil) then
					if object.config[loadIndex] == nil then
						object.config[loadIndex] = table.create(0, 1)
					end
					
					sprite:writeConfig(object.config[loadIndex])
				end
				
				sprite:remove()
				
				if _spritesToRecycle[object.id] ~= nil then
					table.insert(self.spritesToRecycle[object.id], sprite)
				end
			end
		end
	end
end

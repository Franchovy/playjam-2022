
class("SpriteCycler").extends()

function SpriteCycler:init(chunkLength)
	self.chunkLength = chunkLength
	self.data = {}
end

function SpriteCycler:load(config)
	self.numChunks = math.ceil(config.levelSize / self.chunkLength)
	
	-- Create chunks
	
	for i=1,self.numChunks do
		table.insert(self.data, createChunk())
	end
	
	-- Set sprite positions in level
	
	for _, object in pairs(config.objects) do
		local chunk = math.ceil((object.position.x + 1) / self.chunkLength)
		
		-- For now, only accept positive integer chunks.
		if chunk > 0 then
			local spriteData = createSpritePositionData(object)
			
			setSpritePositionData(self.data, chunk, spriteData)
		end
	end
	
	print("Loaded config:")
	printTable(self.data)
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

function createChunk()
	return {
		sprites = {},
		state = "positioned"
	}
end

function createSpritePositionData(object)
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

function setSpritePositionData(data, chunk, spriteData)
	if data[chunk] == nil then
		fatalError("Chunk has not been loaded! Please check your level config.")
	end
	
	table.insert(data[chunk].sprites, spriteData)
end
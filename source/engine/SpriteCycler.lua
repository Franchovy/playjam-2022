
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
		local chunk = math.ceil(object.position.x + 1 / self.chunkLength)
		
		local spriteData = createSpritePositionData(object.id, object.config)
		
		setSpritePositionData(self.data, chunk, object.position, spriteData)
	end
	
	printTable(self.data)
end

function createChunk()
	return {
		positions = {},
		state = "positioned"
	}
end

function createSpritePositionData(id, config)
	return {
		id = id,
		config = config,
		isActive = false
	}
end

function setSpritePositionData(data, chunk, position, spriteData)
	if data[chunk] == nil then
		fatalError("Chunk has not been loaded! Please check your level config.")
	end
	
	table.setIfNil(data[chunk], position.x)
	table.setIfNil(data[chunk][position.x], position.y)
	
	data[chunk][position.x][position.y] = spriteData
end
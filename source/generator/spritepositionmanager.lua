import "engine"

class("SpritePositionManager").extends()

function SpritePositionManager:init()
	self.positions = {}
end

SpritePositionManager = SpritePositionManager()

function SpritePositionManager:configure(maxChunks, chunkLength)
	self.maxChunks = maxChunks
	self.chunkLength = chunkLength
end

function SpritePositionManager:generateRandomOffsetsForChunk(count)
	local offsets = {}
	for i=1,count do
		local newOffset = math.random(0, self.chunkLength) -- Chunk size by default
		table.insert(offsets, newOffset)
	end
	return offsets
end

-- Generates a position per chunk to the given position (plus chunk-x-offset)
function SpritePositionManager:setSinglePositionForSprite(name, position)
	local spritePositions = {}
	
	for i=1,self.maxChunks do
		spritePositions[i] = {}
		
		local chunkXOffset = (i - 1) * self.chunkLength
		
		table.insert(spritePositions[i], {
			x = position.x + chunkXOffset,
			y = position.y
		})
	end
	
	self.positions[name] = spritePositions
end

function SpritePositionManager:populate(name, yRange, spriteCount)
	local spritePositions = {}
	
	spritePositions[1] = {}
	
	for i=2,self.maxChunks + 1 do
		
		spritePositions[i] = {}
		
		local chunkXOffset = (i - 1) * self.chunkLength
		local positionsX = self:generateRandomOffsetsForChunk(spriteCount)
		
		for _, x in pairs(positionsX) do
			local yRangeMin, yRangeMax = table.unpack(yRange)
			
			table.insert(spritePositions[i], 
			 	{ 
				 	y = math.random(yRangeMin, yRangeMax),
				 	x = chunkXOffset + x
			 	}
			)
		end
	end
	
	spritePositions[#spritePositions + 1] = {}
	
	self.positions[name] = spritePositions
end

function SpritePositionManager:getPositionsInChunk(name, chunk) 
	if self.positions[name] == nil or
		self.positions[name][chunk] == nil then
			print("Chunk does not exist: ".. name.. "[".. chunk.. "]")
		return {}
	end
	
	return self.positions[name][chunk]
end
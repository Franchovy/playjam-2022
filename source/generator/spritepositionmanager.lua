import "engine"

class("SpritePositionManager").extends()

function SpritePositionManager:init()
	self.positions = {}
end

SpritePositionManager = SpritePositionManager()

function SpritePositionManager:generateRandomOffsetsForChunk(count)
	local offsets = {}
	for i=1,count do
		local newOffset = math.random(0, 1000) -- Chunk size by default
		table.insert(offsets, newOffset)
	end
	return offsets
end

function SpritePositionManager:populate(name, yRange, spriteCount)
	-- Automatically populate 10 chunks
	local spritePositions = {}
	for i=1,10 do
		spritePositions[i] = {}
		local chunkXOffset = (i - 1) * 1000
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
	
	print("Created table of sprite positions: ")
	printTable(spritePositions)
	--print("Setting sprite positions for: ".. name)
	self.positions[name] = spritePositions
end

function SpritePositionManager:getPositionsInChunk(name, chunk) 
	print("Getting sprite positions for: ".. name .. ", chunk: " ..chunk)
	--print("Response: ".. #self.positions[name][chunk])
	if self.positions[name] == nil or
		self.positions[name][chunk] == nil then
			print("Chunk does not exist: ".. name.. "[".. chunk.. "]")
		return {}
	end
	
	return self.positions[name][chunk]
end
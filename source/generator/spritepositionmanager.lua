import "engine"

class("SpritePositionManager").extends()

function SpritePositionManager:init()
	self.positions = {}
end

SpritePositionManager = SpritePositionManager()

function SpritePositionManager:populate(name, yRange, xIntervalRange)
	-- Automatically populate 10 chunks
	local spritePositions = {}
	for i=1,10 do
		spritePositions[i] = {}
		local chunkXOffset = (i - 1) * 1000
		local nextX = 0
		local previousX = 0
		while (nextX < 1000) do
		 	table.insert(spritePositions[i], 
				 { 
					 y = math.random(yRange.top, yRange.bottom),
					 x = nextX 
				 }
			 )
		 	previousX = nextX
		 	nextX = math.random(previousX + xIntervalRange.left, previousX + xIntervalRange.right)
	 	end
	end
	--print("Setting sprite positions for: ".. name)
	self.positions[name] = spritePositions
end

function SpritePositionManager:getPositionsInChunk(name, chunk) 
	--print("Getting sprite positions for: ".. name .. ", chunk: " ..chunk)
	--print("Response: ".. #self.positions[name][chunk])
	if self.positions[name] == nil or
		self.positions[name][chunk] == nil then
			print("Chunk does not exist: ".. name.. "[".. chunk.. "]")
		return {}
	end
	
	return self.positions[name][chunk]
end
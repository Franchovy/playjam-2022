import "engine"

class("SpritePositionManager").extends()

SpritePositionManager = SpritePositionManager()

function SpritePositionManager:init()
	self.positions = {}
end

function SpritePositionManager:populate(name, yRange, xIntervalRange)
	-- Automatically populate 10 chunks
	local spritePositions = {}
	for i=1,10 do
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
	
	self.positions[name] = spritePositions
end

function SpritePositionManager:getPositionsInChunk(name, chunk) 
	return self.positions[name][chunk]
end
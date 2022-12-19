import "engine"

class("ChunkGenerator").extends()

function ChunkGenerator:init()
	
end

ChunkGenerator = ChunkGenerator()

function ChunkGenerator:configure(maxChunks, chunkLength) 
	self.maxChunks = maxChunks
	self.chunkLength = chunkLength
	
	self.chunksGenerated = {}
end

function ChunkGenerator:initialLoadChunks(count)
	for i=0,count-1 do
		table.insert(self.chunksGenerated, i)
		
		SpriteData:loadSpritesInChunk(i)
	end
end

function ChunkGenerator:updateChunks()
	
	-- Calculate current chunk
	local currentChunk = math.floor((-gfx.getDrawOffset()) / self.chunkLength)
	
	-- Chunks to be generated next
	local nextChunk = currentChunk + 2
	local previousChunk = currentChunk - 1
	
	-- If chunks are not yet generated / in range
	if nextChunk > self.chunksGenerated[4] and nextChunk <= self.maxChunks then
		
		self.chunksGenerated = {
			currentChunk - 1,
			currentChunk,
			currentChunk + 1,
			currentChunk + 2
		}
		
		SpriteData:recycleSpritesInChunk(self.chunksGenerated[1])
		SpriteData:loadSpritesInChunk(nextChunk)
		
	elseif previousChunk >= 0 and previousChunk < self.chunksGenerated[1] then
		
		self.chunksGenerated = {
			currentChunk - 1,
			currentChunk,
			currentChunk + 1,
			currentChunk + 2
		}
		
		SpriteData:recycleSpritesInChunk(self.chunksGenerated[4])
		SpriteData:loadSpritesInChunk(previousChunk)
	end
end
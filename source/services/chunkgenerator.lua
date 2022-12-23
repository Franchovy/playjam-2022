import "engine"

ChunkGenerator = {}

function ChunkGenerator.new(numChunks)
	local chunks = {}
	
	for i=1,numChunks do
		chunks[i] = {}
	end
	
	return chunks
end
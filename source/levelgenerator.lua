import "engine"

generator = {}

-- -----------------
-- Sprite positions: 
-- SpriteClass : positions array [ {x, y} ]
local spritePositions = {}
-- -----------------
-- Levels generated:
-- Array (true | false) (sprites loaded or not)
local chunksGenerated = {}
-- -----------------
-- Sprites Assigned:
-- [sprites : false | number]
-- Sprite to assigned level / not assigned
-- For all sprites
local spritesAssigned = {}

local floorPlatforms = {}

local CHUNK_WIDTH = 3000
local maxChunks = 7

function spritePositions:generateSpritePositions(minX, maxX, minY, maxY, numEntities)
	--print("Generating sprite positions")
	local positions = {}
	for i=1,numEntities do
		positions[i] = {
			x = math.random(minX, maxX),
			y = math.random(minY, maxY)
		}
	end

	return positions
end




-- --------------
-- Generator

function generator:getPositiveScreenOffset()
	return -gfx.getDrawOffset()
end

function generator:setSpawnPattern(name, minY, maxY, numEntitiesPerDifficulty)
	maxChunks = math.max(maxChunks, #numEntitiesPerDifficulty)
	for i, numEntities in ipairs(numEntitiesPerDifficulty) do
		if spritePositions[i] == nil then
			spritePositions[i] = {}
		end
		
		local offsetX = (i - 1) * CHUNK_WIDTH
		spritePositions[i][name] = spritePositions:generateSpritePositions(
			offsetX, 
			offsetX + CHUNK_WIDTH, 
			minY, 
			maxY, 
			numEntities
		)
	end
end

function generator:setSpawnPositions(name, x, y, numEntitiesPerDifficulty)
	maxChunks = math.max(maxChunks, #numEntitiesPerDifficulty)
	for i, numEntities in ipairs(numEntitiesPerDifficulty) do
		if spritePositions[i] == nil then
			spritePositions[i] = {}
		end
		
		local offsetX = (i - 1) * CHUNK_WIDTH
		spritePositions[i][name] = spritePositions:generateSpritePositions(offsetX + x, offsetX + x, y, y, numEntities)
	end
end

function generator:generateChunk(chunk)
	-- Ignore if chunk does not exist
	if chunk < 1 or chunk > maxChunks then
		return
	end
	
	chunksGenerated[chunk] = true
	
	-- Get pre-loaded sprite positions for this chunk
	for name, positions in pairs(spritePositions[chunk]) do
		local sprites = loadedSprites[name]
		local positionIndex = 1
		for i, position in ipairs(positions) do
			-- Find the next sprite that is currently unassigned
			local sprite = table.getFirst(sprites, function (s) return spritesAssigned[s] == false end)
			if sprite ~= nil then
				-- Assign position to this sprite
				sprite:moveTo(position.x, position.y)
				spritesAssigned[sprite] = chunk
			end
		end
	end
end

function generator:degenerateChunk(chunk)
	-- Ignore if chunk does not exist
	if chunk < 1 or chunk > maxChunks then
		return
	end
	
	chunksGenerated[chunk] = false
	
	-- Assign sprites to positions
	for name, positions in pairs(spritePositions[chunk]) do
		local sprites = loadedSprites[name]
		for _, sprite in ipairs(sprites) do
			if spritesAssigned[sprite] == chunk then
				-- Assign position
				spritesAssigned[sprite] = false
			end
		end
	end
end


function generator:loadLevelBegin()
	
	-- Register unloaded levels
	for i=1,maxChunks do chunksGenerated[i] = false end
	
	-- Assign sprites to positions in chunk 1
	self:generateChunk(1)
	
	-- Update sprites in view (sprite:add/remove)
	self:updateSpritesInView()
end

function generator:degenerateAllLevels()
	for i=1,maxChunks do
		if chunksGenerated[i] then
			self:degenerateChunk(i)
		end
	end
end

function generator:updateLevelIfNeeded()
	local currentScreenOffsetX = self:getPositiveScreenOffset()
	
	local chunkNeedsGenerating = nil
	
	if currentScreenOffsetX % CHUNK_WIDTH > CHUNK_WIDTH / 2 then
		-- Set needs load next level
		chunkNeedsGenerating = currentLevel + 1
	else
		-- Set needs load previous level
		chunkNeedsGenerating = currentLevel - 1
	end
	
	-- Ignore for first level
	if chunkNeedsGenerating < 1 then
		return
	end
	
	if chunksGenerated[chunkNeedsGenerating] == true then
		return
	else
		--print("Generating level: " .. chunkNeedsGenerating)
		self:generateChunk(chunkNeedsGenerating)
		
		if (chunkNeedsGenerating == currentLevel + 1) then
			self:degenerateChunk(currentLevel - 1)
		elseif (chunkNeedsGenerating == currentLevel - 1) then
			self:degenerateChunk(currentLevel + 1)
		end
	end
end

function generator:update()
	currentLevel = math.floor(self:getPositiveScreenOffset() / CHUNK_WIDTH) + 1
	--print("Current Level: " .. currentLevel)
	
	self:updateSpritesInView()
	self:updateLevelIfNeeded()
end

function generator:updateSpritesInView()
	local currentScreenOffsetX = self:getPositiveScreenOffset()
	local minGeneratedX = currentScreenOffsetX - 400
	local maxGeneratedX = currentScreenOffsetX + 400 + 400
	
	for _, sprites in pairs(loadedSprites) do
		for _, sprite in pairs(sprites) do
			-- TODO: ISSUE - Why are sprites remaining all unassigned?
			-- Ignore sprites that are not assigned
			--print(spritesAssigned[sprite])
			if spritesAssigned[sprite] == false then return end
			
			if sprite.x < minGeneratedX and sprite.x + sprite.width < minGeneratedX then
				-- Sprite is out of screen (left)
				--print("Removing " .. sprite.type)
				--sprite:remove()
			elseif sprite.x > maxGeneratedX and sprite.x + sprite.width > maxGeneratedX then
				-- Sprite is out of screen (right)
				--print("Removing " .. sprite.type)
				--sprite:remove()
			else
				--print("Adding " .. sprite.type)
				--sprite:add()
			end
		end
	end
end

function generator:removeAllSprites()
	for _, sprites in pairs(loadedSprites) do
		for _, sprite in pairs(sprites) do
			sprite:remove()
		end
	end
end
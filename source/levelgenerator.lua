import "engine"

generator = {}

-- ---------------
-- Loaded Sprites:
-- [list of sprite instances]
-- spawnPattern --deprecated
-- verticalSpawnRange --deprecated
local loadedSprites = {}
-- -----------------
-- Sprite positions: 
-- SpriteClass : positions array [ {x, y} ]
local spritePositions = {}

local levelsGenerated = {}
local spritesAssigned = {}

local LEVEL_WIDTH = 3000
local maxLevels = 9

function spritePositions:generateSpritePositions(minY, maxY, numEntities)
	local positions = {}
	for i=1,numEntities do
		positions[i] = {
			math.random(minY, maxY),
			math.random(0, LEVEL_WIDTH)
		}
	end

	return positions
end

function generator.registerSprite(self, spriteClass, maxInstances, ...)
	loadedSprites[spriteClass] = {}
	
	for i=1,maxInstances do
		local sprite = spriteClass.new(...)
		loadedSprites[spriteClass][i] = { sprite = sprite }
		spritesAssigned[sprite] = false
	end
end

function generator:getPositiveScreenOffset()
	return -gfx.getDrawOffset()
end

function generator:setSpawnPattern(spriteClass, minY, maxY, numEntitiesPerDifficulty)
	--loadedSprites[spriteClass].verticalSpawnRange = { minY, maxY }
	--loadedSprites[spriteClass].spawnPattern = numEntitiesPerDifficulty
	
	maxLevels = math.max(maxLevels, #numEntitiesPerDifficulty)
	for i, numEntities in ipairs(numEntitiesPerDifficulty) do
		if spritePositions[i] == nil then
			spritePositions[i] = {}
		end
		
		spritePositions[i][spriteClass] = spritePositions:generateSpritePositions(minY, maxY, numEntities)
	end
end

function generator:generateLevel(level)
	-- Ignore if level does not exist
	if level < 1 or level > maxLevels then
		return
	end
	
	levelsGenerated[level] = true
	
	-- Assign sprites to positions
	for spriteClass, positions in pairs(spritePositions[level]) do
		local sprites = loadedSprites[spriteClass]
		local positionIndex = 1
		for i, position in ipairs(positions) do
			-- Find the next sprite that is currently unassigned
			local spriteTable = table.getFirst(sprites, function (s) return spritesAssigned[s.sprite] == false end)
			if spriteTable ~= nil then
				local sprite = spriteTable.sprite
				-- Assign position to this sprite
				sprite:moveTo(position[1], position[2])
				spritesAssigned[sprite] = level
			end
		end
	end
end

function generator:degenerateLevel(level)
	-- Ignore if level does not exist
	if level < 1 or level > maxLevels then
		return
	end
	
	levelsGenerated[level] = false
	
	-- Assign sprites to positions
	for spriteClass, positions in pairs(spritePositions[level]) do
		local sprites = loadedSprites[spriteClass]
		for _, s in ipairs(sprites) do
			local sprite = s.sprite
			if spritesAssigned[sprite] == level then
				-- Assign position
				spritesAssigned[sprite] = false
			end
		end
	end
end


function generator:loadLevelBegin()
	
	-- Register unloaded levels
	for i=1,maxLevels do levelsGenerated[i] = false end
	
	-- Assign sprites to positions in levels 1
	self:generateLevel(1)
	
	-- Update sprites in view (sprite:add/remove)
	self:updateSpritesInView()
end

function generator:updateLevelIfNeeded()
	local currentScreenOffsetX = self:getPositiveScreenOffset()
	
	local levelNeedsGenerating = nil
	
	if currentScreenOffsetX % LEVEL_WIDTH > LEVEL_WIDTH / 2 then
		-- Set needs load next level
		levelNeedsGenerating = currentLevel + 1
	else
		-- Set needs load previous level
		levelNeedsGenerating = currentLevel - 1
	end
	
	-- Ignore for first level
	if levelNeedsGenerating < 1 then
		return
	end
	
	if levelsGenerated[levelNeedsGenerating] == true then
		return
	else
		print("Generating level: " .. levelNeedsGenerating)
		self:generateLevel(levelNeedsGenerating)
		
		if (levelNeedsGenerating == currentLevel + 1) then
			self:degenerateLevel(currentLevel - 1)
		elseif (levelNeedsGenerating == currentLevel - 1) then
			self:degenerateLevel(currentLevel + 1)
		end
	end
end

function generator:update()
	currentLevel = math.floor(self:getPositiveScreenOffset() / LEVEL_WIDTH) + 1
	print("Current Level: " .. currentLevel)
	
	self:updateSpritesInView()
	self:updateLevelIfNeeded()
end

function generator:updateSpritesInView()
	local currentScreenOffsetX = self:getPositiveScreenOffset()
	local minGeneratedX = currentScreenOffsetX - 400
	local maxGeneratedX = currentScreenOffsetX + 400 + 400
	
	for _, spriteConfigList in pairs(loadedSprites) do
		for _, spriteConfig in pairs(spriteConfigList) do
			if spriteConfig.sprite.x > minGeneratedX and spriteConfig.sprite.x < maxGeneratedX then
				spriteConfig.sprite:add()
			else
				spriteConfig.sprite:remove()
			end
		end
	end
end

function generator:removeAllSprites()
	for _, spriteConfigList in pairs(loadedSprites) do
		for _, spriteConfig in pairs(spriteConfigList) do
			spriteConfig.sprite:remove()
		end
	end
end
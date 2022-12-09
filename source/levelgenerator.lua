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
-- -----------------
-- Levels generated:
-- Array (true | false) (sprites loaded or not)
local levelsGenerated = {}
-- -----------------
-- Sprites Assigned:
-- [sprites : false | number]
-- Sprite to assigned level / not assigned
-- For all sprites
local spritesAssigned = {}

local floorPlatforms = {}

local LEVEL_WIDTH = 3000
local maxLevels = 9

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

function generator.registerSprite(self, name, spriteClass, maxInstances, ...)
	loadedSprites[name] = {}
	
	for i=1,maxInstances do
		local sprite = spriteClass.new(...)
		loadedSprites[name][i] = { sprite = sprite }
		spritesAssigned[sprite] = false
	end
end

function generator:getPositiveScreenOffset()
	return -gfx.getDrawOffset()
end

function generator:setSpawnPattern(name, minY, maxY, numEntitiesPerDifficulty)
	maxLevels = math.max(maxLevels, #numEntitiesPerDifficulty)
	for i, numEntities in ipairs(numEntitiesPerDifficulty) do
		if spritePositions[i] == nil then
			spritePositions[i] = {}
		end
		
		local offsetX = (i - 1) * LEVEL_WIDTH
		spritePositions[i][name] = spritePositions:generateSpritePositions(
			offsetX, 
			offsetX + LEVEL_WIDTH, 
			minY, 
			maxY, 
			numEntities
		)
	end
end

function generator:setSpawnPositions(name, x, y, numEntitiesPerDifficulty)
	maxLevels = math.max(maxLevels, #numEntitiesPerDifficulty)
	for i, numEntities in ipairs(numEntitiesPerDifficulty) do
		if spritePositions[i] == nil then
			spritePositions[i] = {}
		end
		
		local offsetX = (i - 1) * LEVEL_WIDTH
		spritePositions[i][name] = spritePositions:generateSpritePositions(offsetX + x, offsetX + x, y, y, numEntities)
		printTable(spritePositions[i][name])
	end
end

function generator:generateLevel(level)
	-- Ignore if level does not exist
	if level < 1 or level > maxLevels then
		return
	end
	
	levelsGenerated[level] = true
	
	-- Get pre-loaded sprite positions for this level
	for name, positions in pairs(spritePositions[level]) do
		local sprites = loadedSprites[name]
		local positionIndex = 1
		for i, position in ipairs(positions) do
			-- Find the next sprite that is currently unassigned
			local spriteTable = table.getFirst(sprites, function (s) return spritesAssigned[s.sprite] == false end)
			if spriteTable ~= nil then
				local sprite = spriteTable.sprite
				-- Assign position to this sprite
				sprite:moveTo(position.x, position.y)
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
	for name, positions in pairs(spritePositions[level]) do
		local sprites = loadedSprites[name]
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

function generator:degenerateAllLevels()
	for i=1,maxLevels do
		if levelsGenerated[i] then
			self:degenerateLevel(i)
		end
	end
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
		--print("Generating level: " .. levelNeedsGenerating)
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
	--print("Current Level: " .. currentLevel)
	
	self:updateSpritesInView()
	self:updateLevelIfNeeded()
end

function generator:updateSpritesInView()
	local currentScreenOffsetX = self:getPositiveScreenOffset()
	local minGeneratedX = currentScreenOffsetX - 400
	local maxGeneratedX = currentScreenOffsetX + 400 + 400
	
	for _, spriteConfigList in pairs(loadedSprites) do
		for _, spriteConfig in pairs(spriteConfigList) do
			local sprite = spriteConfig.sprite
			if sprite.x < minGeneratedX and sprite.x + sprite.width < minGeneratedX then
				-- Sprite is out of screen (left)
				sprite:remove()
			elseif sprite.x > maxGeneratedX and sprite.x + sprite.width > maxGeneratedX then
				-- Sprite is out of screen (right)
				sprite:remove()
			else
				spriteConfig.sprite:add()
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
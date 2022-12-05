import "engine"

generator = {}

local loadedSprites = {}

function generator.registerSprite(self, spriteClass, maxInstances, ...)
	loadedSprites[spriteClass] = {}
	
	for i=1,maxInstances do
		loadedSprites[spriteClass][i] = { sprite = spriteClass.new(...) }
	end
end

function generator:setSpritePositions(spriteClass, positions)
	for i,position in ipairs(positions) do
		loadedSprites[spriteClass][i].position = position
	end
end

function generator:setSpritePositionsRandomGeneration(spriteClass, initialX, minSpacingX, maxSpacingX, minY, maxY)
	local previousX = initialX
	for i,spriteConfig in ipairs(loadedSprites[spriteClass]) do
		local x = previousX + math.random(minSpacingX, maxSpacingX)
		local y = math.random(minY, maxY)
		previousX += x
		
		spriteConfig.position = {x = x, y = y}
	end
end

function generator:loadLevelBegin()
	for _, spriteConfigList in pairs(loadedSprites) do
		for _, spriteConfig in pairs(spriteConfigList) do
			spriteConfig.sprite:moveTo(spriteConfig.position.x, spriteConfig.position.y)
		end
	end
	
	self:updateSpritesInView()
end

function generator:update()
	self:updateSpritesInView()
end

function generator:updateSpritesInView()
	local currentScreenOffsetX = gfx.getDrawOffset()
	local minGeneratedX = -currentScreenOffsetX - 400
	local maxGeneratedX = -currentScreenOffsetX + 400 + 400
	
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
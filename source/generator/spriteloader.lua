import "engine"
import "levelgenerator"

class("SpriteLoader").extends()

function SpriteLoader:init()
	-- All existing registered sprites sorted by "name"
	self.sprites = {
		-- "name" = { list of sprite objects }
	}
	
	-- Keeps assignment status of sprites
	self.assignedSprites = {
		-- <sprite object> = <boolean isAssigned?>
	}
	
	-- Initializer function for each registered sprite type "name"
	self.initializeSprite = {
		-- "name" = <initalizer function>
	}
		
end

-- Singleton class
SpriteLoader = SpriteLoader()

-- Public Functions

function SpriteLoader:createSprite(name, spriteClass, maxInstances, ...)
	-- Create sprite list if not existing
	if self.sprites[name] == nil then
		self.sprites = {}
	end
	
	for i=1,maxInstances do
		-- Create new sprite from arguments
		local sprite = spriteClass(...)
		
		-- Set assigned status to false
		self.assignedSprites[newSprite] = false
		
		-- Add sprite to sprite lists
		self:insertSprite(name, sprite)
	end
end

function SpriteLoader:getAllSprites() 
	-- Return all sprites as flattened list
	local sprites = {}
	for _, spritesOfType in pairs(self:getLoadedSprites()) do
		for _, sprite in ipairs(spritesOfType) do
			table.insert(sprites, sprite)
		end
	end
	return sprites
end

function SpriteLoader:loadSprite(name)
	-- Get sprite if existing
	local reusedSprite = table.getFirst(self.sprites[name], function (s) self:isSpriteAssigned(s) end)
	
	-- Set assigned status to true
	self.assignedSprites[reusedSprite] = true
	
	-- Return existing sprite
	return reusedSprite
end

function SpriteLoader.unloadSprite(sprite)
	self.assignedSprites[sprite] = false
end

-- Helper functions

function SpriteLoader:insertSprite(name, sprite)
	-- Add sprite to sprite list
	if self.sprites[name] ~= nil then
		-- Add to existing list
		table.insert(self.sprites[name], sprite)
	else
		-- Create new list
		self.sprites[name] = { sprite }
	end
end

function SpriteLoader:isSpriteAssigned(sprite)
	return self.assignedSprites[sprite] == true
end

function SpriteLoader:getLoadedSprites()
	-- Return full sprite list
	return self.sprites
end
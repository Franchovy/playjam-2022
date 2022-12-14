import "engine"
import "levelgenerator"

SpriteLoader = {}

function isSpriteAssigned()
	
end

function generator.registerSprite(self, name, spriteClass, maxInstances, ...)
	self.sprites[name] = {}
	
	for i=1,maxInstances do
		local sprite = spriteClass.new(...)
		self.sprites[name][i] = sprite
		self.assignedSprites[sprite] = false
	end
end

function generator:getLoadedSprites()
	return self.sprites
end

function SpriteLoader.getSprites() 
	local sprites = {}
	for _, spritesOfType in pairs(generator:getLoadedSprites()) do
		for _, sprite in ipairs(spritesOfType) do
			table.insert(sprites, sprite)
		end
	end
	return sprites
end

function SpriteLoader.loadSprite(name)
	local reusedSprite = table.getFirst(self.sprites[name], function (s) isSpriteAssigned(s) end)
end

function SpriteLoader.unloadSprite()
	
end
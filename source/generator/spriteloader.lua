import "engine"
import "levelgenerator"

SpriteLoader = {}

function SpriteLoader.getSprites() 
	local sprites = {}
	for _, spritesOfType in pairs(generator:getLoadedSprites()) do
		for i, sprite in ipairs(spritesOfType) do
			table.insert(sprites, sprite)
		end
	end
	return sprites
end
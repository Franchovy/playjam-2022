import "engine"
import "generator/spriteloader"

SpriteSpawner = {}

function SpriteSpawner.update() 
	local currentScreenOffsetX = -gfx.getDrawOffset()
	local sprites = SpriteLoader.getSprites()
	
	local minGeneratedX = currentScreenOffsetX - 400
	local maxGeneratedX = currentScreenOffsetX + 400 + 400
	
	for _, sprite in pairs(sprites) do
		if (sprite.x + sprite.width < minGeneratedX) or (sprite.x > maxGeneratedX) then
			-- Sprite is out of loaded area
			sprite:remove()
		else
			-- Sprite is out of loaded area
			sprite:add()
		end
	end
end
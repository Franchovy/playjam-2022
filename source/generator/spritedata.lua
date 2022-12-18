import "engine"
import "spriteloader"

class("SpriteData").extends()

function SpriteData:init()
	self.spriteData = {}
end

SpriteData = SpriteData()

function SpriteData:registerSprite(name, className, initParams, positioningData)
	table.insert(self.spriteData, {
		name = name,
		className = className,
		positioningData = positioningData,
		initParams = initParams,
	})
	
	SpriteLoader:registerSprite(name)
end

function SpriteData:generatePositions()
	for _, spriteData in pairs(self.spriteData) do
		SpritePositionManager:populate(spriteData.name, spriteData.positioningData.yRange, spriteData.positioningData.numSpritesPerChunk)
	end
end

function SpriteData:reloadSpritesInChunk(chunk)
	for _, spriteData in pairs(self.spriteData) do
		local spritePositions = SpritePositionManager:getPositionsInChunk(spriteData.name, chunk)
		
		for _, position in pairs(spritePositions) do
			local name = spriteData.name
			local className = spriteData.className
			local args = spriteData.initParams
			
			-- Reuse or create new sprite
			local sprite = SpriteLoader:loadSprite(name)
			if sprite == nil then
				sprite = SpriteLoader:createSprite(name, className, args)
			end
			
			-- Move sprite to assigned position
			sprite:moveTo(position.x, position.y)
			
			-- TODO: Set Difficulty params (based on chunk)
		end
	end
end
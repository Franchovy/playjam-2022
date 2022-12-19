import "engine"
import "spriteloader"

class("SpriteData").extends()

function SpriteData:init()
	self.spriteData = {}
end

SpriteData = SpriteData()

function SpriteData:registerSprite(name, className, positioningData)
	local spriteData = {
		name = name,
		className = className,
		positioningData = positioningData,
	}
	
	local index = table.firstIndex(self.spriteData, function(s) return s.name == name end)
	 	or table.insert(self.spriteData, spriteData)
	
	if index ~= nil then
		self.spriteData[index] = spriteData
	end
	
	SpriteLoader:registerSprite(name)
end

function SpriteData:setInitializerParams(name, ...)
	local i = table.firstIndex(self.spriteData, function (s) return s.name == name end)
	self.spriteData[i].initParams = {...}
end

function SpriteData:setPositioning(name, numSpritesPerChunk, positioningData)
	SpritePositionManager:populate(name, positioningData.yRange, numSpritesPerChunk)
end

function SpriteData:reloadSpritesInChunk(chunk)
	for _, spriteData in pairs(self.spriteData) do
		local spritePositions = SpritePositionManager:getPositionsInChunk(spriteData.name, chunk)
		
		for _, position in pairs(spritePositions) do
			local name = spriteData.name
			local className = spriteData.className
			local args = spriteData.initParams or nil
			
			-- Reuse or create new sprite
			local sprite = SpriteLoader:loadSprite(name)
			if sprite == nil then
				sprite = SpriteLoader:createSprite(name, className, table.unpack(args))
			end
			
			-- Move sprite to assigned position
			sprite:moveTo(position.x, position.y)
			
			-- TODO: Set Difficulty params (based on chunk)
		end
	end
end
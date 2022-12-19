import "engine"
import "spriteloader"

class("SpriteData").extends()

function SpriteData:init()
	self.spriteData = {}
	self.chunkAssignedSprites = {}
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

function SpriteData:loadSpritesInChunk(chunk)
	print("Loading sprites in chunk: ".. chunk)
	
	for _, spriteData in pairs(self.spriteData) do
		local spritePositions = SpritePositionManager:getPositionsInChunk(spriteData.name, chunk)
		local spritesAdded = {}
		
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
			
			table.insert(spritesAdded, sprite)
		end
		
		if self.chunkAssignedSprites[spriteData.name] == nil then
			self.chunkAssignedSprites[spriteData.name] = {}
		end
		
		self.chunkAssignedSprites[spriteData.name][chunk] = spritesAdded
	end
end

function SpriteData:recycleSpritesInChunk(chunk)
	print("Recycling sprites in chunk: ".. chunk)
	
	for _, spriteData in pairs(self.spriteData) do
		local sprites = self.chunkAssignedSprites[spriteData.name][chunk]
		
		for _, sprite in pairs(sprites) do
			SpriteLoader:unassignSprite(sprite)
		end
		
		self.chunkAssignedSprites[spriteData.name][chunk] = nil
	end
end
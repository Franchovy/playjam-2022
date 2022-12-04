import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "extensions"

-- Libraries

local gfx <const> = playdate.graphics

-- Publicly exposed properties

collisionHandler = {}

collisionResponseTypes = {
	slide = gfx.sprite.kCollisionTypeSlide,
	overlap = gfx.sprite.kCollisionTypeOverlap,
	freeze = gfx.sprite.kCollisionTypeFreeze,
	bounce = gfx.sprite.kCollisionTypeBounce,
}

-----------------------------------
-- Collision Configurations Handler

local configurations = {}

-- Properties

configurations.configuredSprites = {}

-- Methods

function configurations:addConfiguration(object, targetType, collisionResponseType)
	local configurationArray = nil
	
	if self.configuredSprites[object] ~= nil then
		-- Retrieve existing array
		configurationArray = self.configuredSprites[object]
	else
		-- Create new Array
		configurationArray = {}
	end
	
	-- Add configuration to array
	local configuration = { object, targetType, collisionResponseType }
	
	configurationArray[1] = configuration
	
	-- Set sprite configurations on self
	self.configuredSprites[object] = configurationArray
end

function configurations:getConfigurationsForSprite(object)
	return self.configuredSprites[object]
end

-- ===================== --
-- --------------------- --

-- Collision Handler

-- --

-- Methods

function collisionHandler:setCollidesForObject(object, targetType, collisionResponseType)
	configurations:addConfiguration(object, targetType, collisionResponseType)
end

function collisionHandler:getCollisionsFor(object)
	local collisions = {}
	
	local configurationsArray = configurations:getConfigurationsForSprite(object)
	print(configurationsArray)
	printTable(configurations)
	for i=1,#configurationsArray do
		local _, targetType, collisionResponseType = configurationsArray[i]
		
		collisions[i] = targetType, collisionResponseType
	end
	
	return collisions
end

-- WHEEL SPRITE COLLISIONS

-- table.each(collisions,
-- 	function (collision)
-- 		if collision.other.type ~= nil and
-- 			collision.other.type == "KillBlock" then
-- 				
-- 				-- Perform alpha collision check
-- 				if self:alphaCollision(collision.other) then
-- 					-- Kill player if touched
-- 					self:setIsDead()
-- 					sampleplayer:playSample("drop")
-- 				end
-- 		elseif collision.other.type ~= nil and --new
-- 			collision.other.type == "Coin" then
-- 				self:increaseScore()
-- 				collision.other:destroy()
-- 		elseif collision.other.type ~= nil and --new
-- 			collision.other.type == "Wind" then
-- 				self.currentWindPower=collision.other.windPower
-- 
-- 		end
-- 	end
-- )


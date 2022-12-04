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

--

-- Properties

local latestCollisions = {}

-------------------------------------
-- Sprite automatic CollisionResponse

function collisionHandler:setCollidesForSprite(object, targetType, collisionResponseType)
	configurations:addConfiguration(object, targetType, collisionResponseType)
end

function collisionHandler:activateCollisionsResponsesForSprite(object)
	local configurations = self:getCollisionConfigurationsForSprite(object)
	
	-- Writes collision response function for this sprite
	object.collisionResponse = function (object, other)
		for _, configuration in pairs(configurations) do
			-- If 'other' matches configuration target type
			if other.type == configuration.targetType then
				-- Return programmed collision response
				return configurations.collisionResponseType
			end
		end
	end
end
-- Suggestion: return collision response function instead of setting it.

---------------------
-- Collision handling

-- Set 'latestCollisions', from Sprite:moveWithCollisions() or Sprite:checkCollisions()
function collisionHandler:updateCollisionForSprite(object, collisions)
	latestCollisions[object] = collisions
end

-- Clear 'latestCollisions' at the end of every Sprite.update()
function collisionHandler:update()
	-- TODO: check for memory leak
	latestCollisions = {}
end


-- Returns collisions that have happened in the latest update in handy format: Dict { collision.other = collision } where 'collision' is the same as returned from sprite:moveWithCollisions or sprite:checkCollisions. [see doc]
function collisionHandler:getCollisionsForSprite(object)
	local configurations = self:getCollisionConfigurationsForSprite(object)
	local latestCollisions = latestCollisions[object]
	local returnCollisions = {}
	
	-- When no collisions array exists, something went wrong.
	if latestCollisions == nil then
		error("ERROR - Sprite is missing collisions. Call 'Sprite.update' as well as '<your sprite>:moveWithCollisions()' or '<your sprite>:checkCollisions()' before making this call.")
		return
	end
	
	-- Loop over collisions and return in nice format
	for i=1,#latestCollisions do
		local collision = latestCollisions[i]
		for _, configuration in pairs(configurations) do
			if collision.other.type == configuration.targetType then
				returnCollisions[collision.other] = collision
			end
		end
	end
	
	return returnCollisions
end

function collisionHandler:getCollisionConfigurationsForSprite(object)
	local collisionConfigurations = {}
	
	-- Get current configurations set for this object
	local configurations = configurations:getConfigurationsForSprite(object)
	
	-- Transform into friendly syntax
	for i=1,#configurations do
		local _, targetType, collisionResponse = configurations[i]
		
		collisionConfigurations[i] = { targetType = targetType, collisionResponse = collisionResponse }
	end
	
	-- Return collision configurations
	return collisionConfigurations
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


import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "extensions"

-- Libraries

local gfx <const> = playdate.graphics

---------------------------------------
-- Configuration Handler (helper class)

class("ConfigurationHandler").extends()

-- Initializer

function ConfigurationHandler:init() 
	-- Set properties
	
	self.configuredSprites = {}
end

-- Other Methods

function ConfigurationHandler:addConfiguration(object, targetType, collisionResponseType)
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
	
	table.insert(configurationArray, configuration)
	
	-- Set sprite configurations on self
	self.configuredSprites[object] = configurationArray
end

function ConfigurationHandler:getConfigurationsForSprite(object)
	local collisionConfigurations = {}
	
	-- Get current configurations set for this object
	local configurations = self.configuredSprites[object]
	
	-- Transform into friendly syntax
	for i, v in ipairs(configurations) do
		local _, targetType, collisionResponseType = table.unpack(v)
		
		collisionConfigurations[i] = { 
			targetType = targetType, 
			collisionResponseType = collisionResponseType 
		}
	end
	
	-- Return collision configurations
	return collisionConfigurations
end

--

--

-- ================= --
-- Collision Handler --


class("CollisionHandler").extends()

---------------
-- Initializer

function CollisionHandler:init() 
	self.latestCollisions = {}
	self.configurationHandler = ConfigurationHandler()
	
end

-- Globally available instance 'collisionHandler'
collisionHandler = CollisionHandler()

-------------------------------------
-- Sprite collision response (slide, freeze, overlap, )

function CollisionHandler:setCollidesForSprite(object, targetType, collisionResponseType)
	self.configurationHandler:addConfiguration(object, targetType, collisionResponseType)
end

function CollisionHandler:activateCollisionResponsesForSprite(object)
	local configurations = self.configurationHandler:getConfigurationsForSprite(object)
	if configurations == nil then
		error("ERROR: - No collision configurations were set.")
		return
	end
	
	-- Writes collision response function for this sprite
	object.collisionResponse = function(object, other)
		for _, configuration in pairs(configurations) do
			-- If 'other' matches configuration target type
			if other.type == configuration.targetType then
				-- Return programmed collision response
				return configuration.collisionResponseType
			end
		end
		
		return playdate.kCollisionTypeOverlap
	end
end
-- Suggestion: return collision response function instead of setting it.


---------------------
-- Collision handling

-- Set 'latestCollisions', from Sprite:moveWithCollisions() or Sprite:checkCollisions()
function CollisionHandler:updateCollisionForSprite(object, collisions)
	self.latestCollisions[object] = collisions
end

-- Clear 'latestCollisions' at the end of every Sprite.update()
function CollisionHandler:update()
	-- TODO: check for memory leak
	self.latestCollisions = {}
end

-- Returns all the collisions that have happened in the latest 
-- update in a handy format: { collision.other = collision } 
-- (where 'collision' object is the same format as returned by 
-- sprite:moveWithCollisions() or by sprite:checkCollisions(). 
--
function CollisionHandler:getCollisionsForSprite(object)
	local configurations = self.configurationHandler:getConfigurationsForSprite(object)
	
	if configurations == nil then
		error("ERROR: - No collision configurations were set for sprite.")
		return
	end
	
	local latestCollisions = self.latestCollisions[object]
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
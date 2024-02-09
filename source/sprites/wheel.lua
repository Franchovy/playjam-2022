import "engine"
import "engine/colliderSprite"
import "constant"
import "utils/images"
import "playdate"
import "engine/debugCanvas"

local gfx <const> = playdate.graphics

-- The wheel itself contains lots of physical parameters and interactions that should be placed in some kind of "Rigidbody" class
-- for simplicity everything was stuffed inside wheel since it's supposed to be the only dynamic element of the game
class("Wheel").extends(ColliderSprite)

local gravity <const> = 10
local dt <const> = 1 / 30

function Wheel.new() 
	return Wheel()
end

function Wheel:init()
	Wheel.super.init(self)
	
	self.imagetable = gfx.imagetable.new(kAssetsImages.wheel)
	
	self:setImage(self.imagetable[1])
	self:setCenter(0, 0)
	
	self.type = kSpriteTypes.player
	
	local x, y, w, h = self:getBounds()
	self:setCollider(kColliderType.circle, circleNew(x + w / 2, y + h / 2, w / 2))
	self:setCollisionType(kCollisionType.dynamic)
	self:readyToCollide()
	
	self.collisionResponse = function(self, other)
		if other.type == kSpriteTypes.platform then
			return kCollisionResponse.slide
		end
		
		return kCollisionResponse.overlap
	end
	
	self.signals = {}
	
	-- Samples
	
	-- Load sound assets
	
	sampleplayer:addSample("coin", kAssetsSounds.coin, 0.5)
	sampleplayer:addSample("bump", kAssetsSounds.bump, 0.3)
	sampleplayer:addSample("land", kAssetsSounds.land, 0.2)
	sampleplayer:addSample("jump", kAssetsSounds.jump, 0.2)
	sampleplayer:addSample("death"..1, kAssetsSounds.death1, 0.6)
	sampleplayer:addSample("death"..2, kAssetsSounds.death2, 0.6)
	sampleplayer:addSample("death"..3, kAssetsSounds.death3, 0.6)
	sampleplayer:addSample(kAssetsSounds.tick, kAssetsSounds.tick, 0.2)
	sampleplayer:addSample(kAssetsSounds.rev, kAssetsSounds.rev, 1)
	
	-- Synth
	
	local sampleSynth = sampleplayer:getSample(kAssetsSounds.rev)
	local synthConfig = {
		sample = sampleSynth,
		attack = 0.5,
		decay = 1.2,
		volume = 0.12,
		frequency = 440
	}
	
	synth:create(kAssetsSounds.rev, synthConfig)		
	
	-- Create Properties
	
	self:resetValues()
end

function Wheel:setParametersFromJson()
	local wheelParams = json.decodeFile("assets/gameplay/wheel_config.json")
	self.mass = wheelParams.mass
	self.maxJumpCount = wheelParams.maxJumpCount
	self.jumpForce = wheelParams.jumpForce
	print("loaded wheel parameters")
end

function Wheel:resetValues()
	self:setParametersFromJson()

	self.useGravity = true
	self.currentJumpCount = 0
	self.isJumping = false
	self.appliedForces = {}
	
	self.hasJumpedFinished = nil
	self.jumpTimeInTicks = nil
	self.velocityX = 0
	self.velocityY = 0
	self.angle = 0
	self.hasJustDied = false
	self.isAwaitingInput = false
	self.ignoresPlayerInput = true
	self.hasReachedLevelEnd = false
	self.hasTouchedNewCheckpoint = false
	self.hasJustTouchedGround = false
	self._recentCheckpoint = nil
	self._coinCountUpdate = 0
	self.isFrozen = false
	self.normal = {
		x = 0,
		y = 0
	}
	self.normalPrevious = table.shallowcopy(self.normal)
end

function Wheel:getCoinCountUpdate()
	return self._coinCountUpdate
end

function Wheel:setIsDead() 
	if self.hasJustDied then
		return
	end
	
	local random = math.random(3)
	sampleplayer:playSample("death"..random)
	
	-- Freeze all wheel behaviour, no movement or accepted input
	self.ignoresPlayerInput = true
	self.hasJustDied = true
	self.isFrozen = true
	
	if self.signals.onDeath ~= nil then
		self.signals.onDeath()
	end
end

function Wheel:getRecentCheckpoint()
	self.hasTouchedNewCheckpoint = false
	return self._recentCheckpoint
end

function Wheel:startGame()
	self.ignoresPlayerInput = false
end

function Wheel:hasReachedLevelEnd()
	return self.hasReachedLevelEnd
end

function Wheel:setAwaitingInput() 
	self.isAwaitingInput = true
end

function Wheel:collisionWith(other, resolutionX, resolutionY)
	-- nullify velocity in case of collision
	if resolutionX ~= 0 then
		self.velocityX = 0
	end

	if resolutionY ~= 0 then
		self.velocityY = 0
	end

	if other:getCollisionType() == kCollisionType.static then
		if self.isJumping and other.y > self.y then
			self:hitGround()
		end
	end
end

function Wheel:hitGround()
	self.currentJumpCount = 0
	self.isJumping = false
end

function Wheel:checkDeadzone()
	if self.y > 260 and not self.hasJustDied then
		self:setIsDead()
		return
	end
end

function Wheel:shouldJump()
	local jumpButtonPressed = playdate.buttonJustPressed(playdate.kButtonUp) or playdate.buttonJustPressed(playdate.kButtonB)
	return jumpButtonPressed and self.currentJumpCount < self.maxJumpCount
end

function Wheel:jump()
	self.currentJumpCount += 1
	self.isJumping = true

	-- remove velocity if falling, otherwise the jump would be attenuated by the fall
	if self.velocityY > 0 then
		self.velocityY = 0
	end
	
	table.insert(self.appliedForces, {x = 0, y = -self.jumpForce})
end

function Wheel:calculateAcceleration()
	local accelX, accelY = 0, 0
	if self.useGravity then
		accelY += gravity
	end

	for _, force in pairs(self.appliedForces) do
		if (self.mass == 1) then
			accelX += force.x
			accelY += force.y
		else
			accelX += force.x / self.mass
			accelY += force.y / self.mass
		end
	end

	return accelX, accelY
end

function Wheel:updateVelocity(accelX, accelY)
	-- we'd normally multiply accel by dt but we are bypassing that otherwise force values would have to be quite large
	self.velocityX += accelX
	self.velocityY += accelY
end

function Wheel:updatePosition(velocityX, velocityY)
	self:moveTo(self.x + velocityX * dt, self.y + velocityY * dt)
end

function Wheel:clearAppliedForces()
	self.appliedForces = {}
end

-- Movement
function Wheel:update()
	-- important, update the physics
	Wheel.super:update()

	-- kill the wheel when out of map
	self:checkDeadzone();

	if self:shouldJump() then
		self:jump()
	end

	local accelX, accelY = self:calculateAcceleration()
	self:updateVelocity(accelX, accelY)
	self:updatePosition(self.velocityX, self.velocityY)

	self:clearAppliedForces()

	--[[
	local input = self.input
	
	-- Update if player has died
	
	
	-- Ignore input 
	
	local crankTicks
	
	if self.ignoresPlayerInput == false then
		-- Player Input
		
		-- Has just pressed jump
		-- Is holding jump (Jump timer)

		if (playdate.buttonJustReleased(playdate.kButtonUp) or playdate.buttonJustReleased(playdate.kButtonB)) and self.isJumping then
			self:endJump()
		end
		
		if (playdate.buttonIsPressed(playdate.kButtonUp) or playdate.buttonIsPressed(playdate.kButtonB)) then
			self:applyJump()
		end
		
		crankTicks = playdate.getCrankTicks(crankTicksPerCircle)
		
		local ticks = crankTicks / 12
		currentTicks += ticks
		
		if math.abs(previousTicks - currentTicks) >= 1 then
			sampleplayer:playSample(kAssetsSounds.tick)
			previousTicks = currentTicks
		end
	else
		crankTicks = 0
	end
	
	local previousBounds = { self:getBounds() }
	
	-- Reset values that get re-calculated
	
	self.touchingGround = false
	self._coinCountUpdate = 0
	
	self.normalPrevious.x = self.normal.x
	self.normalPrevious.y = self.normal.y
	
	-- Update position according to velocity
	
	local actualX, actualY, collisions, length = self:moveWithCollisions(
		self.x + self.velocityX, 
		self.y + self.velocityY
	)

	-- Collisions-based updates
	
	local normalUpdate = { x = 0, y = 0 }
	
	for _, collision in pairs(collisions) do
		local target = collision.other
		if target.type == kSpriteTypes.platform then
			if collision.normal.x ~= 0 then 
				--horizontal collision
				self.velocityX = 0
				normalUpdate.x = collision.normal.x
			end
			
			if collision.normal.y == -1 then 
				--top collision
				self.touchingGround = true
				
				self:resetJumpState()
			end
			
			if collision.normal.y ~= 0 then
				normalUpdate.y = collision.normal.y
			end
		elseif target.type == kSpriteTypes.coin then
			if target:isVisible() and self:alphaCollision(target) then
				-- Win some points
				sampleplayer:playSample("coin")
				target:isGrabbed()
				self._coinCountUpdate += 1
			end
		elseif target.type == kSpriteTypes.killBlock then
			if self:alphaCollision(target) then
				-- Die
				self:setIsDead()
			end
		elseif target.type == kSpriteTypes.checkpoint then
			if not target:isSet() then
				target:set()
				self.hasTouchedNewCheckpoint = true
				self._recentCheckpoint = {x = target.x, y = target.y}
				
				self.signals.onTouchCheckpoint()
			end
		elseif target.type == kSpriteTypes.levelEnd then
			if self:alphaCollision(target) then
				if self.hasReachedLevelEnd then
					self.signals.onLevelComplete()
				end
				
				self.hasReachedLevelEnd = true
			end
		end
	end
	
	if self.hasJustDied == false then	
		self.normal.x = normalUpdate.x
		self.normal.y = normalUpdate.y
		
		if self.normal.x ~= 0 and self.normalPrevious.x == 0 then
			sampleplayer:playSample("bump")
		end
		
		if self.normal.y == -1 and self.normalPrevious.y == 0 then
			sampleplayer:playSample("land")
		end
		
		if self.normal.y == 1 and self.normalPrevious.y == 0 then
			sampleplayer:playSample("bump")
		end
		
		-- Play sounds based on movement
		local maxVelocityX = 11 -- this has been copied from speed.lua
		local velocityFactor = math.abs(self.velocityX) / maxVelocityX
		
		local frequencyFactor = (velocityFactor + 1) * 2.5
		local volumeFactor = (velocityFactor + 1)
		
		synth:play(kAssetsSounds.rev, frequencyFactor, volumeFactor)
	end
	
	-- Update graphics
	
	self.angle = self.angle - self.velocityX / 5
	
	if self.angle > 12 then 
		self.angle = self.angle % 12 
	end
	if self.angle < 1 then 
		self.angle += 12 
	end
	
	local imageIndex = math.floor(self.angle)

	self:setImage(self.imagetable[imageIndex])
	
	local currentBounds = { self:getBounds() }
	if (previousBounds[1] ~= currentBounds[1]) or 
		(previousBounds[2] ~= currentBounds[2]) or 
		(previousBounds[3] ~= currentBounds[3]) or 
		(previousBounds[4] ~= currentBounds[4]) then
		local drawOffsetX, _ = gfx.getDrawOffset()
		gfx.sprite.addDirtyRect(previousBounds[1] + drawOffsetX, previousBounds[2], previousBounds[3], previousBounds[4])
		gfx.sprite.addDirtyRect(currentBounds[1] + drawOffsetX, currentBounds[2], currentBounds[3], currentBounds[4])
	end
	]]
end

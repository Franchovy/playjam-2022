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

local gravity <const> = 400
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
	self._radius = w / 2
	self:setCollider(kColliderType.circle, circleNew(x + w / 2, y + h / 2, self._radius))
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
		volume = 0.10,
		frequency = 440
	}
	
	synth:create(kAssetsSounds.rev, synthConfig)		
	
	-- Create Properties
	
	self:resetValues()
end

function Wheel:setParametersFromJson()
	local wheelParams = json.decodeFile("assets/gameplay/wheel_config.json")
	self._maxLinearSpeed = wheelParams.maxLinearSpeed
	self._frictionCoeff = wheelParams.frictionCoeff
	self._maxFallSpeed = wheelParams.maxFallSpeed
	self.mass = wheelParams.mass
	self._crankLength = wheelParams.crankLength
	self.maxJumpCount = wheelParams.maxJumpCount
	self.jumpForce = wheelParams.jumpForce
end

function Wheel:resetValues()
	self:setParametersFromJson()

	self.useGravity = true
	self._currentJumpCount = 0
	self._isJumping = false
	self._jumpHeldTime = 0
	self._appliedForces = {}
	
	self.velocityX = 0
	self.velocityY = 0
	self.angle = 0
	self.hasJustDied = false
	self.isAwaitingInput = false
	self.ignoresPlayerInput = true
	self.hasReachedLevelEnd = false
	self._recentCheckpoint = nil
	self._recentLoadingCheckpoint = nil
	self._isLoadingCheckpoint = false
	self._coinCountUpdate = 0
	self.isFrozen = false
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

function Wheel:hitCheckpoint(checkpoint)
	self.hasTouchedNewCheckpoint = true
	self._recentCheckpoint = checkpoint

	if self.signals.onTouchCheckpoint ~= nil then
		self.signals.onTouchCheckpoint()
	end
end

function Wheel:levelComplete()
	if self.signals.onLevelComplete ~= nil then
		self.signals.onLevelComplete()
	end
end

function Wheel:pickedUpCoin()
	self._coinCountUpdate += 1
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
	if other:getCollisionType() == kCollisionType.static then
		local absResoX = math.abs(resolutionX)
		local absResoY = math.abs(resolutionY)
		-- nullify velocity
		if absResoX >= 0.1 and absResoX > absResoY then
			self.velocityX = 0
		elseif absResoY >= 0.1 and absResoY > absResoX then
			self.velocityY = 0

			if self._isJumping and other.y > self.y then
				self:hitGround()
			end
		end
		
	end
end

function Wheel:hitGround()
	self._currentJumpCount = 0
	self._isJumping = false
	self._jumpHeldTime = 0
end

function Wheel:checkDeadzone()
	if self.y > 260 and not self.hasJustDied then
		self:setIsDead()
		return
	end
end

function Wheel:moveWheel()
	-- this line prevents the wheel from accumulating acceleration forces despite already being at max spd
	if math.abs(self.velocityX) >= self._maxLinearSpeed then return end

	local rotationalChange = playdate.getCrankChange()

	table.insert(self._appliedForces, {x=rotationalChange * self._radius * self._crankLength, y=0})
end

function Wheel:shouldJump()
	local jumpButtonPressed = playdate.buttonIsPressed(playdate.kButtonUp) or playdate.buttonIsPressed(playdate.kButtonB)
	return jumpButtonPressed and self._currentJumpCount < self.maxJumpCount
end

function Wheel:jump()
	self._currentJumpCount += 1
	self._isJumping = true

	-- remove velocity if falling, otherwise the jump would be attenuated by the fall
	if self.velocityY > 0 then
		self.velocityY = 0
	end
	
	table.insert(self._appliedForces, {x = 0, y = -self.jumpForce})
end

function Wheel:calculateAcceleration()
	local accelX, accelY = 0, 0

	-- apply gravity as an acceleration
	if self.useGravity then
		accelY += gravity
	end

	-- apply friction
	if math.abs(self.velocityX) > 1 then
		local frictionDirection = -math.sign(self.velocityX)
		table.insert(self._appliedForces, {x=frictionDirection * self._frictionCoeff * gravity, y=0})
	else
		-- rounded to 0
		self.velocityX = 0
	end
	
	for _, force in pairs(self._appliedForces) do
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
	self.velocityX += accelX * dt
	self.velocityY += accelY * dt
end

function Wheel:updatePosition(velocityX, velocityY)
	velocityX = math.clamp(velocityX, -self._maxLinearSpeed, self._maxLinearSpeed)

	if velocityY > self._maxFallSpeed then
		velocityY = self._maxFallSpeed
	end

	self:moveTo(self.x + velocityX * dt, self.y + velocityY * dt)
end

function Wheel:clearAppliedForces()
	self._appliedForces = {}
end

function Wheel:updateMovements()
	if self:shouldJump() then
		self:jump()
	end

	self:moveWheel()

	local accelX, accelY = self:calculateAcceleration()
	self:updateVelocity(accelX, accelY)
	self:updatePosition(self.velocityX, self.velocityY)

	self:clearAppliedForces()
end

function Wheel:updateGraphics()
	local numImages<const> = 12
	local sliceAngle<const> = 360 / numImages

	local angularVelocity = (self.velocityX / self._radius) * 180 / 3.14
	self.angle -= angularVelocity * dt

	if self.angle > 360 then
		self.angle = self.angle % 360
	elseif self.angle < 0 then
		self.angle += 360
	end
	
	local imageIndex = math.floor(self.angle / sliceAngle) + 1 -- +1 indices start at 1 and not 0
	self:setImage(self.imagetable[imageIndex])
end

function Wheel:playRevSound()
	local velocityFactor = math.abs(self.velocityX) / self._maxLinearSpeed
	
	local frequencyFactor = (velocityFactor + 1) * 2.5
	local volumeFactor = (velocityFactor + 1)
	
	synth:play(kAssetsSounds.rev, frequencyFactor, volumeFactor)
end

-- Movement
function Wheel:update()
	-- important, update the physics
	Wheel.super:update()

	-- kill the wheel when out of map
	self:checkDeadzone()

	if not self.isFrozen then
		self:updateMovements()
		self:updateGraphics()
	end
	
	if not self.hasJustDied then
		self:playRevSound()
	end
end

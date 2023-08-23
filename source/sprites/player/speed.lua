local speedMultiplier = 6
local acceleration = 0.9
local velocityDragStep = 0.1
local velocityBrakeStep = 0.4
local maxVelocityX = 23

function Wheel:calculateSpeed(crankTicks, velocityCurrent)
	-- Handle moving forward
	local velocityRaw = crankTicks * speedMultiplier
	local velocityActual = math.approach(velocityCurrent, velocityRaw, acceleration)
	
	-- Return speed limited by max speed
	if velocityActual < 0 then
		return math.max(velocityActual, -maxVelocityX)
	else 
		return math.min(velocityActual, maxVelocityX)
	end
end

function Wheel:playMovementSound()
	local normalizedVelocityFactor = math.abs(self.velocityX) / maxVelocityX
	self:playMovementBasedSounds(normalizedVelocityFactor)	
end
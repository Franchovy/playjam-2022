local crankTickMultiplier = 3
local accelerationManual = 1.0
local maxSpeedManual = 8.0

local speedUpAcceleration = 0.01
local speedUpDragAcceleration = 0.1
local speedUpBrakeAcceleration = 1.5

local velocityDragStep = 0.1
local velocityBrakeStep = 0.2
local maxVelocityX = 11

function Wheel:calculateSpeed(crankTicks, speedPreviousActual)
	local crankTicks = crankTicks * crankTickMultiplier
	
	-- Handle update manual
	
	local speedManualBounded = math.clamp(crankTicks, -maxSpeedManual, maxSpeedManual)
	local speedPreviousBounded = math.clamp(speedPreviousActual, -maxSpeedManual, maxSpeedManual)
	local speedManualActual = math.approach(
		speedPreviousBounded, 
		speedManualBounded, 
		accelerationManual
	)
	
	-- Handle speed-up
	
	local speedUpActual = 0
	
	if math.abs(speedPreviousActual) >= maxSpeedManual then
		local speedUpPreviousActual = math.sign(speedPreviousActual) * (math.abs(speedPreviousActual) - maxSpeedManual)
		
		if math.sign(speedManualActual) == math.sign(speedPreviousActual) then
			-- Apply Speed up
			
			speedUpActual = speedUpPreviousActual + crankTicks * speedUpAcceleration 
		end
	end
	
	-- Assign actual speed
	
	local speedActual = speedManualActual + speedUpActual
	
	-- Return speed limited by max speed
	
	if speedActual < 0 then
		return math.max(speedActual, -maxVelocityX)
	else 
		return math.min(speedActual, maxVelocityX)
	end
end

function Wheel:playMovementSound()
	local normalizedVelocityFactor = math.abs(self.velocityX) / maxVelocityX
	self:playMovementBasedSounds(normalizedVelocityFactor)	
end
-- Constants

local jumpSpeed = 24
local smallJumpSpeed = 8

local smallJumpMaxTicks = 6
local jumpMaxTicks = 12

-- State

local isJumping = false
local hasJumpedFinished = nil
local jumpTimeInTicks = nil

function Wheel:resetJumpState()
	isJumping = false
	hasJumpedFinished = false
	jumpTimeInTicks = 0
end

function Wheel:canApplyJump()
	return not hasJumpedFinished and (self.isTouchingGround or isJumping)
end

function Wheel:applyJump()
	if hasJumpedFinished then
		return
	end
	
	isJumping = self.touchingGround or jumpTimeInTicks > 0
	
	if isJumping then
		jumpTimeInTicks += 1
		
		if self.touchingGround then
			self.velocityY = -jumpSpeed
		end
	end
	
	if jumpTimeInTicks > jumpMaxTicks then
		hasJumpedFinished = true
	end
end

function Wheel:isJumping() 
	return isJumping
end

function Wheel:endJump()
	print("Ticks: ".. jumpTimeInTicks)
	
	if isJumping and jumpTimeInTicks < smallJumpMaxTicks then
		print("Small jump!")
		self.velocityY = -smallJumpSpeed
	end
	
	hasJumpedFinished = true
end

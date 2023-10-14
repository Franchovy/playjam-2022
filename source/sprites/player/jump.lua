-- Constants

local jumpSpeed = 18
local smallJumpSpeed = 4.5

local smallJumpMaxTicks = 10
local jumpMaxTicks = 14

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
	if isJumping and jumpTimeInTicks < smallJumpMaxTicks then
		self.velocityY = -smallJumpSpeed
	end
	
	isJumping = false
	hasJumpedFinished = true
end

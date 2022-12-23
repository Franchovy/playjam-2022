import "engine"

function defaultBlinker(blinkDuration, blinkOffDuration)
	local blinker = gfx.animation.blinker.new()
	
	blinker.default = false
	blinker.onDuration = blinkDuration or 750
	blinker.offDuration = blinkOffDuration or blinkDuration or 600
	
	return blinker
end
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/animation"

local gfx <const> = playdate.graphics

gfx.blinker = gfx.animation.blinker

-- default(blinkDuration, [blinkOffDuration])
function gfx.blinker.default(blinkDuration, blinkOffDuration)
	local blinker = gfx.animation.blinker.new()
	
	blinker.default = false
	blinker.onDuration = blinkDuration
	blinker.offDuration = blinkOffDuration or blinkDuration
	
	return blinker
end
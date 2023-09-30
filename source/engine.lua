import "CoreLibs/animation"
import "CoreLibs/animator"
import "CoreLibs/crank"
import "CoreLibs/easing"
import "CoreLibs/frameTimer"
import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "engine/lib"
import "extensions"

-- Libraries

geometry = playdate.geometry
gfx = playdate.graphics
timer = playdate.timer
frameTimer = playdate.frameTimer
sprite = playdate.sprite
sound = playdate.sound

-- ===============
-- Shortcuts

easingFunctions = playdate.easingFunctions

colors = {
	white = gfx.kColorWhite,
	black = gfx.kColorBlack,
	xor = gfx.kColorXOR,
	clear = gfx.kColorClear
}

collisionTypes = {
	slide = gfx.sprite.kCollisionTypeSlide,
	overlap = gfx.sprite.kCollisionTypeOverlap,
	freeze = gfx.sprite.kCollisionTypeFreeze,
	bounce = gfx.sprite.kCollisionTypeBounce,
}


textAlignment = {
	center = playdate.kTextAlignmentCenter,
	left = playdate.kTextAlignmentLeft,
	right = playdate.kTextAlignmentRight
}

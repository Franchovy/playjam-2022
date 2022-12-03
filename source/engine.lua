import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"
import "CoreLibs/animator"


import "extensions"
import "params"

-- Libraries

geometry = playdate.geometry
gfx = playdate.graphics
timer = playdate.timer

-- Shortcuts

collisionTypes = {
	slide = gfx.sprite.kCollisionTypeSlide,
	overlap = gfx.sprite.kCollisionTypeOverlap,
	freeze = gfx.sprite.kCollisionTypeFreeze,
	bounce = gfx.sprite.kCollisionTypeBounce,
}

buttons = {
	isLeftButtonPressed = function() return playdate.buttonIsPressed(playdate.kButtonLeft) end,
	isRightButtonPressed = function() return playdate.buttonIsPressed(playdate.kButtonRight) end,
	isDownButtonPressed = function() return playdate.buttonIsPressed(playdate.kButtonDown) end,
	isUpButtonPressed = function() return playdate.buttonIsPressed(playdate.kButtonUp) end
}
import "CoreLibs/sprites"

local sprite <const> = playdate.graphics.sprite

kCollisionResponse = {
	overlap = sprite.kCollisionTypeOverlap,
	slide = sprite.kCollisionTypeSlide,
	bounce = sprite.kCollisionTypeBounce,
	freeze = sprite.kCollisionTypeFreeze
}
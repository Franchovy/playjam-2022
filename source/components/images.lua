import "CoreLibs/object"
import "CoreLibs/graphics"

local graphics <const> = playdate.graphics

kImages = {}

kImages.wheel = {
	"images/wheel_v3/new_wheel1",
	"images/wheel_v3/new_wheel2",
	"images/wheel_v3/new_wheel3",
	"images/wheel_v3/new_wheel4",
	"images/wheel_v3/new_wheel5",
	"images/wheel_v3/new_wheel6",
	"images/wheel_v3/new_wheel7",
	"images/wheel_v3/new_wheel8",
	"images/wheel_v3/new_wheel9",
	"images/wheel_v3/new_wheel10",
	"images/wheel_v3/new_wheel11",
	"images/wheel_v3/new_wheel12",
}

kImages.wind = {
	"images/winds/wind1",
	"images/winds/wind2",
	"images/winds/wind3",
	"images/winds/wind4"
}

kImages.coin = "images/coin"
kImages.killBlock = "images/kill_block_v2"

function getImage(path)
	return graphics.image.new(path)
end

kSpriteImageType = {
	default,
	animated
}

function setSpriteImage(sprite, path, type)
	if type == nil or type == kSpriteImageType.default then
		sprite:setImage(getImage(path))
	end
end
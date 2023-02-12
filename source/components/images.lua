import "CoreLibs/object"
import "CoreLibs/graphics"
import "extensions"

local graphics <const> = playdate.graphics

kImages = {}

kImages.wheel = "images/wheel_v3/new_wheel"
kImages.wind = "images/winds/wind"
kImages.coin = "images/coin"
kImages.killBlock = "images/kill_block_v2"

function getImage(path, count)
	count = count or ""
	return graphics.image.new(path .. count)
end
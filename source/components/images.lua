import "CoreLibs/object"
import "CoreLibs/graphics"
import "extensions"

local graphics <const> = playdate.graphics

kImages = {}

kImages.wheel = "images/sprites/wheel/wheel_0"
kImages.wind = "images/sprites/wind/wind_0"
kImages.coin = "images/sprites/coin"
kImages.killBlock = "images/sprites/killBlock"

function getImage(path, count)
	count = count or ""
	return graphics.image.new(path .. count)
end
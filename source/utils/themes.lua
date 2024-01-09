import "engine"
import "utils/images"

local gfx <const> = playdate.graphics

class("Theme").extends()

function getParalaxImagesForTheme(theme)
	local filePath = theme[3]
	local backgroundImage = gfx.image.new(filePath.. "/".. 0)
	
	local imageCount = theme[4]
	local images = {}
	for i=1,(imageCount-1) do
		local image = gfx.image.new(filePath.. "/".. i)
		table.insert(images, image)
	end
	
	return {
		images = images,
		background = backgroundImage
	}
end

function getMusicFilepathsForTheme(theme)
	return theme[2].."/intro", theme[2].."/loop"
end

function getForegroundColorForTheme(theme)
	if theme[5] == true then
		return gfx.kColorBlack
	else
		return gfx.kColorWhite
	end
end

function getBackgroundColorForTheme(theme)
	if theme[5] == true then
		return gfx.kColorWhite
	else
		return gfx.kColorBlack
	end
end
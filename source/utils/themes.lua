import "engine"
import "utils/images"

class("Theme").extends()

function getParalaxImagesForTheme(theme)
	local filePath = theme[3]
	local backgroundImage = playdate.graphics.image.new(filePath.. "/".. 0)
	
	local imageCount = theme[4]
	local images = {}
	for i=1,(imageCount-1) do
		local image = playdate.graphics.image.new(filePath.. "/".. i)
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
		return playdate.graphics.kColorBlack
	else
		return playdate.graphics.kColorWhite
	end
end

function getBackgroundColorForTheme(theme)
	if theme[5] == true then
		return playdate.graphics.kColorWhite
	else
		return playdate.graphics.kColorBlack
	end
end
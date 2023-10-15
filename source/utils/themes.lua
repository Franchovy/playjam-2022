import "engine"
import "utils/images"

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

function getMusicFilepathForTheme(theme)
	return theme[2]
end

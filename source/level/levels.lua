import "engine"
import "services/image"

class("Level").extends()

function Level.new(name, musicFilePath, backgroundFilePath, numImagesInBackground) 
	local level = Level()
	level:loadBackground(backgroundFilePath, numImagesInBackground)
	
	return level
end

function Level:init()

end

function Level:loadBackground(backgroundFilePath, numImagesInBackground)
	-- Assign background Image (to draw on)
	self.backgroundImage = gfx.image.new(backgroundFilePath.. "/".. 0)
	
	-- Initialize Properties
	
	self.images = {}
	
	for i=1,(numImagesInBackground-1) do
		self.images[i] = gfx.image.new(backgroundFilePath.. "/".. i)
	end
end

function Level:getParalaxImages()
	return {
		images = self.images,
		background = self.backgroundImage
	}
end


levels = {
	Level.new(
		"Mountain",
		"music/mountain",
		"images/backgrounds/mountain", 5
	),
	Level.new(
		"Space",
		"music/space",
		"images/backgrounds/space", 5
	),
	Level.new(
		"City",
		"music/city",
		"images/backgrounds/city", 4
	)
}

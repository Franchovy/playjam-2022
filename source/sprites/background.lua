import "engine"

class("ParalaxBackground").extends(gfx.sprite)

function autoScaledImage(image)
	local imageWidth, imageHeight = image:getSize()
	return image:scaledImage(400 / imageWidth, 240 / imageHeight)
end

function ParalaxBackground.new(pathname, count)
	return ParalaxBackground(pathname, count)
end

function ParalaxBackground:init(pathname, count)
	local backgroundImage = autoScaledImage(gfx.image.new(pathname.. "/".. "background"))
	ParalaxBackground.super.init(self, backgroundImage)
	
	-- Assign background Image (to draw on)
	self.backgroundImage = backgroundImage
	
	-- Initialize Images
	self.images = {}
	for i=1,count do
		self.images[i] = autoScaledImage(gfx.image.new(pathname.. "/".. i))
	end
	
	-- Draw images on background
	for i, image in pairs(self.images) do
		gfx.pushContext(backgroundImage)
		
		image:draw(0, 0)
		
		gfx.popContext()
	end
end

function ParalaxBackground:setParalaxDrawingRatios()
	
	self.paralaxRatios = {}
	
	-- Assign paralax ratios growing relative to number
	for i, image in pairs(self.images) do
		self.paralaxRatios[i] = 1 / (i * 1000)
	end
end

function ParalaxBackground:setParalaxDrawOffset(drawOffset)
end
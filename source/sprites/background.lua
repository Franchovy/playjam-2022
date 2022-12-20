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
	ParalaxBackground.super.init(self)
	
	self:setSize(400, 240)
	
	-- Assign background Image (to draw on)
	self.backgroundImage = autoScaledImage(gfx.image.new(pathname.. "/".. 0))
	
	-- Initialize Properties
	
	self.images = {}
	self.paralaxRatios = {}
	self.imageOffsets = {}
	
	for i=1,count do
		self.images[i] = autoScaledImage(gfx.image.new(pathname.. "/".. i))
		self.paralaxRatios[i] = 0
		self.imageOffsets[i] = 0
	end
	
	self:setIgnoresDrawOffset(true)
end

function ParalaxBackground:getBackgroundDrawingCallback()
	
	return function (x, y, w, h)
		self.backgroundImage:draw(0, 0)
		
		for i, image in pairs(self.images) do		
			
			local imageOffset = self.imageOffsets[i]
			image:draw(imageOffset, 0)
			
			local imageWidth = image:getSize()
			image:draw(imageOffset + imageWidth, 0)
		end
	end
end

function ParalaxBackground:setParalaxDrawingRatios()
	
	self.paralaxRatios = {}
	
	-- Assign paralax ratios growing relative to number
	for i, image in pairs(self.images) do
		self.paralaxRatios[i] = i / 10
	end
end

function ParalaxBackground:setParalaxDrawOffset(drawOffset)
	print(drawOffset)
	for i, image in pairs(self.images) do
		self.imageOffsets[i] = drawOffset * self.paralaxRatios[i]
	end
end
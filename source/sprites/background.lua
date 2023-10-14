import "engine"

class("ParalaxBackground").extends(gfx.sprite)


function ParalaxBackground.new()
	return ParalaxBackground()
end

function ParalaxBackground:init()
	ParalaxBackground.super.init(self)
	
	self:setSize(playdate.display.getSize())
	self:setUpdatesEnabled(false)
	
	self:setIgnoresDrawOffset(true)
end

function ParalaxBackground:loadForTheme(theme)
	local theme = theme:getParalaxImages()
	
	-- Assign background Image (to draw on)
	self.backgroundImage = theme.background
	
	-- Initialize Properties
	
	self.images = theme.images
	
	self.paralaxRatios = {}
	self.imageOffsets = {}
	
	for i=1,#self.images do
		self.paralaxRatios[i] = 0
		self.imageOffsets[i] = 0
	end
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
		self.paralaxRatios[i] = i / 50
	end
end

function ParalaxBackground:setParalaxDrawOffset(drawOffset)
	for i, image in pairs(self.images) do
		local originalOffset = drawOffset * self.paralaxRatios[i]
		self.imageOffsets[i] = originalOffset % 400 - 400
	end
end

class("WidgetBackground").extends(Widget)

function WidgetBackground:init(config)
	self.theme = config.theme
	
	self:createSprite(kZIndex.background)
	self.sprite:add()
end

function WidgetBackground:_load()
	local images = getParalaxImagesForTheme(kThemes[self.theme])
	
	-- Assign background Image (to draw on)
	self.backgroundImage = images.background
	
	-- Initialize Properties
	
	self.images = images.images
	
	self.paralaxRatios = {}
	self.imageOffsets = {}
	
	for i=1,#self.images do
		self.paralaxRatios[i] = i / 50
		self.imageOffsets[i] = 0
	end
end

function WidgetBackground:_draw(rect)
	self.backgroundImage:draw(rect.x, rect.y)
	
	for i, image in ipairs(self.images) do
		local imageOffset = self.imageOffsets[i]
		local imageWidth = image:getSize()
		-- Draw 2 copies of the image, one before and one after
		-- TODO: Draw only the part of the image needed using [sourcerect]
		image:draw(rect.x + imageOffset + imageWidth, rect.y)
		image:draw(rect.x + imageOffset, rect.y)
	end
end

function WidgetBackground:_update()
	local drawOffset = playdate.graphics.getDrawOffset()
	
	for i, image in pairs(self.images) do
		local originalOffset = drawOffset * self.paralaxRatios[i]
		self.imageOffsets[i] = originalOffset % 400 - 400
	end
end



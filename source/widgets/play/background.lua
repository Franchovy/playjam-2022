
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

function WidgetBackground:_draw(frame, rect)
	if rect == nil then 
		self.backgroundImage:draw(frame.x, frame.y)
	else
		self.backgroundImage:draw(frame.x, frame.y, playdate.graphics.kImageUnflipped, rect.x, rect.y, rect.w, rect.h)
	end
	
	for i, image in ipairs(self.images) do
		local imageOffset = math.floor(self.imageOffsets[i])
		local imageWidth = image:getSize()
		
		-- TODO: Handle drawRect / image source rects overlap
		
		-- Draw 2 copies of the image, one before and one after
		image:draw(frame.x, frame.y, playdate.graphics.kImageUnflipped, -imageOffset, 0, imageWidth - math.abs(imageOffset), 240)
		image:draw(frame.x + imageOffset + imageWidth, frame.y, playdate.graphics.kImageUnflipped, 0, 0, -imageOffset, 240)
	end
end

function WidgetBackground:_update()
	local previousOffset <const> = self.drawOffset
	self.drawOffset = playdate.graphics.getDrawOffset()
	
	for i, image in pairs(self.images) do
		local originalOffset = self.drawOffset * self.paralaxRatios[i]
		self.imageOffsets[i] = originalOffset % 400 - 400
	end
	
	if self.drawOffset ~= previousOffset then
		self.sprite:markDirty()
	end
end



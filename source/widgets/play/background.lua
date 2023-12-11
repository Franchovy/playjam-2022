
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
		local imageWidth, imageHeight = image:getSize()
		
		-- TODO: Handle drawRect / image visible rects overlap
		local imageRightRect = Rect.make(imageOffset, 0, imageWidth, imageHeight)
		local imageLeftRect = Rect.make(imageOffset - 400, 0, imageWidth, imageHeight)
		local screenRect = Rect.make(0, 0, 400, 240)
		
		-- Draw 2 copies of the image, one before and one after
		local imageRightSourceRect = Rect.offset(Rect.overlap(imageRightRect, screenRect), -imageOffset, 0)
		assert(imageRightSourceRect.x == 0)
		assert(imageRightSourceRect.y == 0)
		assert(imageRightSourceRect.w == imageWidth - math.abs(imageOffset))
		assert(imageRightSourceRect.h == 240)
		image:draw(frame.x + imageOffset, frame.y, playdate.graphics.kImageUnflipped, imageRightSourceRect.x, imageRightSourceRect.y, imageRightSourceRect.w, imageRightSourceRect.h)
		
		local imageLeftSourceRect = Rect.offset(Rect.overlap(imageLeftRect, screenRect), imageWidth - imageOffset, 0)
		assert(imageLeftSourceRect.x == imageWidth - imageOffset)
		assert(imageLeftSourceRect.y == 0)
		assert(imageLeftSourceRect.w == imageOffset)
		assert(imageLeftSourceRect.h == 240)
		image:draw(frame.x + imageOffset - imageOffset, frame.y, playdate.graphics.kImageUnflipped, imageLeftSourceRect.x, imageLeftSourceRect.y, imageLeftSourceRect.w, imageLeftSourceRect.h)
	end
end

function WidgetBackground:_update()
	local previousOffset <const> = self.drawOffset
	self.drawOffset = playdate.graphics.getDrawOffset()
	
	for i, image in pairs(self.images) do
		local originalOffset = self.drawOffset * self.paralaxRatios[i]
		self.imageOffsets[i] = originalOffset % 400
	end
	
	if self.drawOffset ~= previousOffset then
		self.sprite:markDirty()
	end
end



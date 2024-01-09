local gfx <const> = playdate.graphics

class("WidgetBackground").extends(Widget)

function WidgetBackground:init(config)
	self.theme = config.theme
	
	self:createSprite(kZIndex.background)
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
		self.backgroundImage:draw(frame.x, frame.y, gfx.kImageUnflipped, rect.x, rect.y, rect.w, rect.h)
	end
	
	for i, image in ipairs(self.images) do
		local imageOffset = math.floor(self.imageOffsets[i])
		local imageWidth, imageHeight = image:getSize()
		
		local imageRightRect = Rect.make(imageOffset, 0, imageWidth, imageHeight)
		local imageLeftRect = Rect.make(imageOffset - 400, 0, imageWidth, imageHeight)
		local screenRect = Rect.make(0, 0, 400, 240)
		
		-- Draw 2 copies of the image, one before and one after
		local imageRightOverlapRect
		if rect == nil then
			imageRightOverlapRect = Rect.overlap(imageRightRect, screenRect)
		else
			imageRightOverlapRect = Rect.overlap(Rect.overlap(imageRightRect, screenRect), rect)
		end
		local imageRightSourceRect = Rect.offset(imageRightOverlapRect, -imageOffset, 0)
		image:draw(frame.x + imageOffset, frame.y, gfx.kImageUnflipped, imageRightSourceRect.x, imageRightSourceRect.y, imageRightSourceRect.w, imageRightSourceRect.h)
		
		local imageLeftOverlapRect
		if rect == nil then
			imageLeftOverlapRect = Rect.overlap(imageLeftRect, screenRect)
		else
			imageLeftOverlapRect = Rect.overlap(Rect.overlap(imageLeftRect, screenRect), rect)
		end
		local imageLeftSourceRect = Rect.offset(imageLeftOverlapRect, imageWidth - imageOffset, 0)
		image:draw(frame.x + imageOffset - imageOffset, frame.y, gfx.kImageUnflipped, imageLeftSourceRect.x, imageLeftSourceRect.y, imageLeftSourceRect.w, imageLeftSourceRect.h)
	end
end

function WidgetBackground:_update()
	local previousOffset <const> = self.drawOffset
	self.drawOffset = gfx.getDrawOffset()
	
	for i, image in pairs(self.images) do
		local originalOffset = self.drawOffset * self.paralaxRatios[i]
		self.imageOffsets[i] = originalOffset % 400
	end
	
	if self.drawOffset ~= previousOffset then
		self.sprite:markDirty()
	end
end



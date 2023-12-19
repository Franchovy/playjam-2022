class("WidgetMenuSettings").extends(Widget)

function WidgetMenuSettings:init(config)
	self.config = config
	
	self.painters = {}
end

function WidgetMenuSettings:_load()
	self.painters.frame = Painter(function(rect)
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.fillRoundRect(rect.x, rect.y, rect.w, rect.h, 8)
		
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.setDitherPattern(0.7, playdate.graphics.image.kDitherTypeDiagonalLine)
		playdate.graphics.fillRoundRect(rect.x, rect.y, rect.w, rect.h, 8)
		
		playdate.graphics.drawTextAligned("SETTINGS MENU", rect.x + rect.w / 2, rect.y + rect.h / 2, kTextAlignment.center)
	end)
	
	local imageScrew1 = playdate.graphics.image.new(kAssetsImages.screw)
	
	local painterCardOutline = Painter(function(rect)
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.setDitherPattern(0.7, playdate.graphics.image.kDitherTypeDiagonalLine)
		playdate.graphics.fillRoundRect(rect.x, rect.y, rect.w, rect.h, 8)
		
		local rectBorder = Rect.inset(rect, 10, 14)
		local rectBorderInner = Rect.inset(rectBorder, 4, 6)
		local rectBorderInnerShadow = Rect.offset(rectBorderInner, -1, -1)
		
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.setDitherPattern(0.3, playdate.graphics.image.kDitherTypeDiagonalLine)
		playdate.graphics.setLineWidth(3)
		playdate.graphics.drawRoundRect(rectBorderInnerShadow.x, rectBorderInnerShadow.y, rectBorderInnerShadow.w, rectBorderInnerShadow.h, 6)
		
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.fillRoundRect(rectBorderInner.x, rectBorderInner.y, rectBorderInner.w, rectBorderInner.h, 6)
		
		local size = imageScrew1:getSize()
		imageScrew1:rotatedImage(90):draw(rect.x + 4, rect.y + 4)
		imageScrew1:rotatedImage(45):draw(rect.x + rect.w - size - 4, rect.y + 4)
		imageScrew1:draw(rect.x + 4, rect.y + rect.h - size - 4)
		imageScrew1:draw(rect.x + rect.w - size - 4, rect.y + rect.h - size - 4)
	end)
	
	self.painters.card = Painter(function(rect)
		-- Painter background
		
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.fillRoundRect(rect.x, rect.y, rect.w, rect.h, 8)
		
		painterCardOutline:draw(rect)
	end)
end

function WidgetMenuSettings:_draw(frame, rect)
	
	local insetRect = Rect.inset(frame, 12, 6)
	
	self.painters.card:draw(insetRect)
end

function WidgetMenuSettings:_update()
	
end
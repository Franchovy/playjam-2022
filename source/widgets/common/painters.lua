local gfx <const> = playdate.graphics

local _setColor <const> = gfx.setColor
local _setDitherPattern <const> = gfx.setDitherPattern
local _setLineWidth <const> = gfx.setLineWidth
local _drawRoundRect <const> = gfx.drawRoundRect
local _fillRoundRect <const> = gfx.fillRoundRect

Painter.commonPainters = {
	outlinePainterThin = Painter.factory(function(rect, state)
		_setColor(gfx.kColorBlack)
		_setDitherPattern(0.2, gfx.image.kDitherTypeDiagonalLine)
		_setLineWidth(1)
		_drawRoundRect(rect.x, rect.y, rect.w, rect.h, 8)
	end),
	outlinePainterThick = Painter.factory(function(rect, state)
		_setColor(gfx.kColorBlack)
		_setLineWidth(3)
		_drawRoundRect(rect.x, rect.y, rect.w, rect.h, 12)
	end),
	darkScreenFillPainter = Painter.factory(function(rect, state)
		_setDitherPattern(0.3, gfx.image.kDitherTypeDiagonalLine)
		_fillRoundRect(rect.x, rect.y, rect.w, rect.h, 12)
	end),
	fillPainterLight = Painter.factory(function(rect, state)
		_setColor(gfx.kColorWhite)
		_setDitherPattern(0.8, gfx.image.kDitherTypeDiagonalLine)
		_fillRoundRect(rect.x, rect.y, rect.w, rect.h, 12)
	end),
	menuCard = Painter.factory(function(rect)
		_setColor(gfx.kColorWhite)
		_fillRoundRect(rect.x, rect.y, rect.w, rect.h, 8)
		
		_setColor(gfx.kColorBlack)
		_setDitherPattern(0.7, gfx.image.kDitherTypeDiagonalLine)
		_fillRoundRect(rect.x, rect.y, rect.w, rect.h, 8)
		
		local rectInset = Rect.inset(rect, 10, 14)
		
		_setColor(gfx.kColorBlack)
		_setDitherPattern(0.3, gfx.image.kDitherTypeDiagonalLine)
		_setLineWidth(3)
		_drawRoundRect(rectInset.x - 4, rectInset.y - 1, rectInset.w, rectInset.h, 6)
		
		_setColor(gfx.kColorWhite)
		_fillRoundRect(rectInset.x - 3, rectInset.y, rectInset.w, rectInset.h, 6)
		
		local imageScrew = gfx.image.new(kAssetsImages.screw)
		local size = imageScrew:getSize()
		
		imageScrew:draw(rect.x + 4, rect.y + rect.h - size - 4)
		imageScrew:drawRotated(rect.x + 6, rect.y + 6, 45)
		imageScrew:drawRotated(rect.x + rect.w - size - 2, rect.y + rect.h - size - 2, 45)
		imageScrew:drawRotated(rect.x + rect.w - size, rect.y + 8, 90)
	end),
	whiteBackgroundFrame = Painter.factory(function(rect)
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRoundRect(rect.x, rect.y, rect.w, rect.h, 8)
		
		gfx.setColor(gfx.kColorBlack)
		gfx.setLineWidth(2)
		gfx.drawRoundRect(rect.x, rect.y, rect.w, rect.h, 8)
	end),
	lockedCover = Painter.factory(function(frame)
		-- Background opaque fill
		gfx.setColor(gfx.kColorBlack)
		gfx.fillRoundRect(frame.x, frame.y, frame.w, frame.h, 7)
		gfx.setColor(gfx.kColorWhite)
		gfx.setDitherPattern(0.8, gfx.image.kDitherTypeScreen)
		gfx.fillRoundRect(frame.x, frame.y, frame.w, frame.h, 7)
		
		-- "Locked" text
		setCurrentFont(kAssetsFonts.twinbee2x)
		local fontHeight = gfx.getFont():getHeight()
		gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
		gfx.drawTextAligned("LOCKED", frame.w / 2, (frame.h - fontHeight) / 2, kTextAlignment.center)
	end),
	roundedCornerImage = Painter.factory(function(frame, state, image) 
		-- Mask image
		local maskImage = gfx.image.new(frame.w, frame.h)
		gfx.pushContext(maskImage)
		maskImage:clear(gfx.kColorBlack)
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRoundRect(frame.x, frame.y, frame.w, frame.h, 7)
		gfx.popContext()
		image:setMaskImage(maskImage)
		
		-- Image
		image:draw(frame.x, frame.y)
		
		-- Overlay
		gfx.setColor(gfx.kColorBlack)
		gfx.setLineWidth(3)
		gfx.drawRoundRect(frame.x, frame.y, frame.w, frame.h, 7)
	end)
}
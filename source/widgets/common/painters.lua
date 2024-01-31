local gfx <const> = playdate.graphics

local _setColor <const> = gfx.setColor
local _setDitherPattern <const> = gfx.setDitherPattern
local _setLineWidth <const> = gfx.setLineWidth
local _drawRoundRect <const> = gfx.drawRoundRect
local _fillRoundRect <const> = gfx.fillRoundRect

Painter.commonPainters = {
	outlinePainterThin = Painter(function(rect, state)
		_setColor(gfx.kColorBlack)
		_setDitherPattern(0.2, gfx.image.kDitherTypeDiagonalLine)
		_setLineWidth(1)
		_drawRoundRect(rect.x, rect.y, rect.w, rect.h, 8)
	end),
	outlinePainterThick = Painter(function(rect, state)
		_setColor(gfx.kColorBlack)
		_setLineWidth(3)
		_setDitherPattern(0.2, gfx.image.kDitherTypeDiagonalLine)
		_drawRoundRect(rect.x, rect.y, rect.w, rect.h, 12)
	end),
	screenFillPainter = Painter(function(rect, state)
		_setDitherPattern(0.8, gfx.image.kDitherTypeScreen)
		_fillRoundRect(rect.x, rect.y, rect.w, rect.h, 12)
	end),
	menuCard = Painter(function(rect)
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
	end)
}
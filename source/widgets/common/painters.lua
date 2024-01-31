local gfx <const> = playdate.graphics

local _setColor <const> = gfx.setColor
local _setDitherPattern <const> = gfx.setDitherPattern
local _setLineWidth <const> = gfx.setLineWidth
local _drawRoundRect <const> = gfx.drawRoundRect

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
	end)
}
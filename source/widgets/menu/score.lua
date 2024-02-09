local gfx <const> = playdate.graphics
local geo <const> = playdate.geometry

class("WidgetMenuScore").extends(Widget)

local cornerRadius <const> = 12
local paddingRight <const> = 8

function WidgetMenuScore:_init()
	self:supply(Widget.deps.frame)
end

function WidgetMenuScore:_load()
	self.painters = {}
	self.painters.background = Painter(function (rect)		
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRoundRect(rect.x, rect.y, rect.w, rect.h, cornerRadius)
		
		gfx.setColor(gfx.kColorBlack)
		gfx.setLineWidth(4)
		gfx.drawRoundRect(rect.x, rect.y, rect.w, rect.h, cornerRadius)
		
		gfx.setColor(gfx.kColorWhite)
		gfx.setLineWidth(4)
		gfx.setDitherPattern(0.5, gfx.image.kDitherTypeDiagonalLine)
		gfx.drawRoundRect(rect.x, rect.y, rect.w, rect.h, cornerRadius)
	end)
end

function WidgetMenuScore:_draw(frame, drawRect)
	self.painters.background:draw(frame)
	
	setCurrentFont(kAssetsFonts.twinbee15x)
	gfx.drawTextAligned("⚪️"..self.config.coins, self.rects.coinText.x, self.rects.coinText.y, kTextAlignment.right)
end

function WidgetMenuScore:_performLayout()
	setCurrentFont(kAssetsFonts.twinbee15x)
	local frame = self.frame
	local fontHeight = gfx.getFont():getHeight()
	
	self.rects.coinText = geo.point.new(frame.x + frame.w - paddingRight, frame.y + (frame.h - fontHeight) / 2)
end
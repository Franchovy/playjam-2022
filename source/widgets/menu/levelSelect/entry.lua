import "widgets/common/painters"

local gfx <const> = playdate.graphics
local geo <const> = playdate.geometry

local _assign <const> = geo.rect.assign
local _tInset <const> = geo.rect.tInset

local _outlinePainterThick <const> = Painter.commonPainters.outlinePainterThick()
local _screenPainterDark <const> = Painter.commonPainters.darkScreenFillPainter()
local _fillPainterLight <const> = Painter.commonPainters.fillPainterLight()
class("LevelSelectEntry").extends(Widget)

function LevelSelectEntry:init(config)
	LevelSelectEntry.super.init(self)
	
	self.config = config
	
	self:supply(Widget.deps.state)
	self:supply(Widget.deps.frame, { needsLayout = true })
	
	local isSelected = config.isSelected == true
	self:setStateInitial({ selected = 1, unselected = 2}, isSelected and 1 or 2)
	
	self.images = {}
	self.painters = {}
end

function LevelSelectEntry:_load()
	self.painters.painter = Painter(function(rect, state)
		setCurrentFont(kAssetsFonts.twinbee2x)
		local fontHeight = gfx.getFont():getHeight()
		local margin = 10

		gfx.drawText(self.config.text, rect.x + margin, rect.y + (rect.h - fontHeight) / 2)
		
		if self.config.locked == true then
			_fillPainterLight:draw(rect)
			_screenPainterDark:draw(rect)
			
			local imageLock = gfx.image.new(kAssetsImages.lock)
			local imageLockW, imageLockH = imageLock:getSize()
			local imageRect = geo.rect.new(rect.x + (rect.w - imageLockW) / 2, rect.y + (rect.h - imageLockH) / 2, imageLockW, imageLockH)
			
			gfx.setColor(gfx.kColorWhite)
			gfx.fillRoundRect(imageRect:insetBy(-8, -2), 4)
			
			gfx.setColor(gfx.kColorBlack)
			gfx.setDitherPattern(0.2, gfx.image.kDitherTypeDiagonalLine)
			gfx.fillRoundRect(imageRect:insetBy(-6, 0), 4)
			
			imageLock:draw(imageRect.x, imageRect.y)
		end
		
		if state.selected == true then
			_outlinePainterThick:draw(rect)
		end
	end)
end

function LevelSelectEntry:_draw(frame, rect)
	self.painters.painter:draw(self.rects.painter, { selected = (self.state == self.kStates.selected) })
end

function LevelSelectEntry:_performLayout()
	local _rects = self.rects
	local _frame = self.frame
	_rects.painter = _tInset(_assign(_rects.painter, _frame), 20, 2)
end

function LevelSelectEntry:_changeState(stateFrom, stateTo)
	
end

function LevelSelectEntry:_unload()
	self.painters = nil
	self.images = nil
end
import "widgets/common/painters"

local gfx <const> = playdate.graphics
local geo <const> = playdate.geometry

local _assign <const> = geo.rect.assign
local _tInset <const> = geo.rect.tInset

local _outlinePainterThick = Painter.commonPainters.outlinePainterThick


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
	_rects.painter = _tInset(_assign(_rects.painter, _frame), 20, 0)
end

function LevelSelectEntry:_changeState(stateFrom, stateTo)
	
end

function LevelSelectEntry:_unload()
	self.painters = nil
	self.images = nil
end
import "utils/value"

class("WidgetEntriesMenuEntry").extends(Widget)

function WidgetEntriesMenuEntry:init(config)
	self.config = config
	
	self:supply(Widget.deps.state)
	self:setStateInitial({ unselected = 1, selected = 2 }, self.config.selected and 2 or 1)
	
	self.images = {}
	self.painters = {}
end

function WidgetEntriesMenuEntry:_load()
	if self.config.scale == 1 then
		setCurrentFont(kAssetsFonts.twinbee)
	elseif self.config.scale == 1.5 then
		setCurrentFont(kAssetsFonts.twinbee15x)
	elseif self.config.scale == 2 then
		setCurrentFont(kAssetsFonts.twinbee2x)
	end
	
	self.images.title = playdate.graphics.imageWithText(self.config.text, 400, 70)
	
	setCurrentFontDefault()
	
	self.painters.circle = Painter(function(rect)
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.fillCircleInRect(rect.x, rect.y, rect.w, rect.h)
		
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.drawCircleInRect(rect.x, rect.y, rect.w, rect.h)
		
		playdate.graphics.setDitherPattern(0.5, playdate.graphics.image.kDitherTypeDiagonalLine)
		playdate.graphics.fillCircleInRect(rect.x, rect.y, rect.w, rect.h)
	end)
end

function WidgetEntriesMenuEntry:_draw(rect)
	local _, titleH = self.images.title:getSize()
	local marginLeft = titleH * 2
	local marginVert = (rect.h - titleH) / 2
	local insetRect = Rect.inset(rect, marginLeft, marginVert, 5)
	
	self.images.title:draw(insetRect.x, insetRect.y)
	
	if self.state == self.kStates.selected then
		local circleSize = math.ceil(titleH * 0.9)
		local circleRect = Rect.with(Rect.size(circleSize, circleSize), { x = math.ceil(rect.x + (marginLeft - circleSize) / 2), y = math.ceil(rect.y + marginVert) })
		self.painters.circle:draw(circleRect)
	end
end

function WidgetEntriesMenuEntry:_update()
	
end

function WidgetEntriesMenuEntry:setState(state)
	for k, v in pairs(state) do
		if self.state[k] ~= v then
			self:_changeState(self.state, state)
			
			self.state[k] = v
		end
	end
end

function WidgetEntriesMenuEntry:_changeState(stateFrom, stateTo)
	
end
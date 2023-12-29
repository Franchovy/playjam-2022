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
	self.images.title = playdate.graphics.imageWithText(self.config.text, 200, 70):scaledImage(self.config.scale)
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
	local insetRect = Rect.inset(rect, 32, 8, 5)
	
	self.images.title:draw(insetRect.x, insetRect.y)
	
	if self.state == self.kStates.selected then
		local insetRect = Rect.inset(rect, 7, 5)
		self.painters.circle:draw(Rect.with(insetRect, { w = 15 }))
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
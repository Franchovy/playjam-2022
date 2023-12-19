class("WidgetMenuSettingsEntry").extends(Widget)

function WidgetMenuSettingsEntry:init(config)
	self.config = config
	
	self:supply(Widget.kDeps.state)
	local isSelected = config.isSelected == true and 1 or 2
	self:setStateInitial({ selected = 1, unselected = 2 }, isSelected)
end

function WidgetMenuSettingsEntry:_load()
	
end

function WidgetMenuSettingsEntry:_draw(frame, rect)
	if self.state == self.kStates.selected then
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.fillRect(frame.x, frame.y, frame.w, frame.h)
	else
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.setDitherPattern(0.6, playdate.graphics.image.kDitherTypeDiagonalLine)
		playdate.graphics.fillRect(frame.x, frame.y, frame.w, frame.h)
	end
end

function WidgetMenuSettingsEntry:_update()
	
end
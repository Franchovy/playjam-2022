class("WidgetMenuSettingsEntry").extends(Widget)

function WidgetMenuSettingsEntry:init(config)
	self.config = config
end

function WidgetMenuSettingsEntry:_load()
	
end

function WidgetMenuSettingsEntry:_draw(frame, rect)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.fillRect(frame.x, frame.y, frame.w, frame.h)
end

function WidgetMenuSettingsEntry:_update()
	
end
class("WidgetMenuSettings").extends(Widget)

function WidgetMenuSettings:init(config)
	self.config = config
end

function WidgetMenuSettings:_load()
	print("Loaded")
end

function WidgetMenuSettings:_draw(frame, rect)
	playdate.graphics.setColor(playdate.graphics.kColorWhite)
	playdate.graphics.fillRect(frame.x, frame.y, frame.w, frame.h)
	
	playdate.graphics.drawTextAligned("SETTINGS MENU", frame.x + frame.w / 2, frame.y + frame.h / 2, kTextAlignment.center)
end

function WidgetMenuSettings:_update()
	
end
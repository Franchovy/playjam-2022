import "entriesMenu/entry"

class("WidgetEntriesMenu").extends(Widget)

function WidgetEntriesMenu:init(config)
	self.config = config
	
	self:supply(Widget.kDeps.state)
	self:supply(Widget.kDeps.children)
	
	self:setStateInitial(self.config, 1)
	
	self.signals = {}
	
	--
	
	self.entries = {}
end

function WidgetEntriesMenu:_load()
	for i=1,#self.config do
		local entry = Widget.new(WidgetEntriesMenuEntry, { text = self.config[i] })
		
		self.children["entry"..i] = entry
		self.entries[i] = entry
	end
end

function WidgetEntriesMenu:_draw(rect)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.setDitherPattern(0.6, playdate.graphics.image.kDitherTypeDiagonalLine)
	playdate.graphics.fillRect(rect.x, rect.y, rect.w, rect.h)
end

function WidgetEntriesMenu:_update()
	local i = 1
	if playdate.buttonJustPressed(playdate.kButtonB) then
		self.signals.entrySelected(i)
	end
end

function WidgetEntriesMenu:changeState(stateFrom, stateTo)
	
end
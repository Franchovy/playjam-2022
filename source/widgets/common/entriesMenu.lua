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
		local entry = Widget.new(WidgetEntriesMenuEntry, { text = self.config[i], selected = i == 1 })
		entry:load()
		
		self.children["entry"..i] = entry
		self.entries[i] = entry
	end
end

function WidgetEntriesMenu:_draw(rect)
	local entryHeight = rect.h / #self.entries
	
	for i, entry in pairs(self.entries) do
		local entryRect = Rect.with(rect, { h = entryHeight, y = rect.y + 10 + (entryHeight * (i - 1)) })
		entry:draw(entryRect)
	end
end

function WidgetEntriesMenu:_update()
	if playdate.buttonJustPressed(playdate.kButtonA) then
		self.signals.entrySelected(self.state)
	end
	
	if playdate.buttonJustPressed(playdate.kButtonDown) then
		if self.state < #self.entries then
			self:setState(self.state + 1)
		end
	end
	
	if playdate.buttonJustPressed(playdate.kButtonUp) then
		if self.state > 1 then
			self:setState(self.state - 1)
		end
	end
end

function WidgetEntriesMenu:changeState(_, stateTo)
	for i, entry in ipairs(self.entries) do
		entry:setState(stateTo == i and entry.kStates.selected or entry.kStates.unselected)
	end
end
import "entriesMenu/entry"

class("WidgetEntriesMenu").extends(Widget)

function WidgetEntriesMenu:init(config)
	self.config = config
	
	self:supply(Widget.deps.state)
	self:supply(Widget.deps.samples)
	
	self:setStateInitial(self.config, 1)
	
	self.signals = {}
	
	--
	
	self.entries = {}
end

function WidgetEntriesMenu:_load()
	for i=1,#self.config.entries do
		local entry = Widget.new(WidgetEntriesMenuEntry, { text = self.config.entries[i], selected = i == 1, scale = self.config.scaleFactor })
		entry:load()
		
		self.children["entry"..i] = entry
		self.entries[i] = entry
	end
	
	self:loadSample(kAssetsSounds.menuSelect)
	self:loadSample(kAssetsSounds.menuSelectFail)
	self:loadSample(kAssetsSounds.menuAccept)
end

function WidgetEntriesMenu:_draw(frame)
	local entryHeight = frame.h / #self.entries
	
	for i, entry in pairs(self.entries) do
		local entryRect = Rect.with(frame, { h = entryHeight, y = frame.y + 10 + (entryHeight * (i - 1)) })
		entry:draw(entryRect)
	end
	
	self.frame = frame
end

function WidgetEntriesMenu:_update()
	if playdate.buttonJustPressed(playdate.kButtonA) or (playdate.buttonJustPressed(playdate.kButtonB)) then
		self:playSample(kAssetsSounds.menuAccept)
				
		self.signals.entrySelected(self.state)
	end
	
	if playdate.buttonJustPressed(playdate.kButtonDown) then
		if self.state < #self.entries then
			self:playSample(kAssetsSounds.menuSelect)
			self:setState(self.state + 1)
			
			if self.frame ~= nil then
				playdate.graphics.sprite.addDirtyRect(self.frame.x, self.frame.y, self.frame.w, self.frame.h)
			end
		else
			self:playSample(kAssetsSounds.menuSelectFail)
		end
	end
	
	if playdate.buttonJustPressed(playdate.kButtonUp) then
		if self.state > 1 then
			self:playSample(kAssetsSounds.menuSelect)
			self:setState(self.state - 1)
			
			if self.frame ~= nil then
				playdate.graphics.sprite.addDirtyRect(self.frame.x, self.frame.y, self.frame.w, self.frame.h)
			end
		else
			self:playSample(kAssetsSounds.menuSelectFail)
		end
	end
end

function WidgetEntriesMenu:changeState(_, stateTo)
	for i, entry in ipairs(self.entries) do
		entry:setState(stateTo == i and entry.kStates.selected or entry.kStates.unselected)
	end
end

function WidgetEntriesMenu:unload()
	for i=1, #self.entries do
		self.children["entry"..i] = nil
		self.entries[i] = nil
	end
	
	self.entries = nil
end
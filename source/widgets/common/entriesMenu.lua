import "entriesMenu/entry"

local gfx <const> = playdate.graphics
local filter <const> = playdate.kButtonA | playdate.kButtonB | playdate.kButtonUp | playdate.kButtonDown

class("WidgetEntriesMenu").extends(Widget)

function WidgetEntriesMenu:init(config)
	self.config = config
	
	self:supply(Widget.deps.state)
	self:supply(Widget.deps.samples)
	self:supply(Widget.deps.input)
	
	self:setStateInitial(self.config, 1)
	
	self.signals = {}
	self.painters = {}
	
	--
	
	self.entries = {}
end

function WidgetEntriesMenu:_load()
	for i=1,#self.config.entries do
		local entry = Widget.new(WidgetEntriesMenuEntry, { text = self.config.entries[i], selected = i == 1, scale = self.config.scale })
		entry:load()
		
		self.children["entry"..i] = entry
		self.entries[i] = entry
	end
	
	if self.config.shouldDrawFrame == true then
		self.painters.background = Painter(function(rect)
			local edgeWidth = 4
			gfx.setColor(gfx.kColorBlack)
			gfx.setLineWidth(edgeWidth)
			gfx.setDitherPattern(0.5)
			
			local insetRect = Rect.inset(rect, edgeWidth, edgeWidth)
			gfx.drawRoundRect(insetRect.x, insetRect.y, insetRect.w, insetRect.h, 8)
			
			gfx.setColor(gfx.kColorWhite)
			gfx.fillRoundRect(insetRect.x, insetRect.y, insetRect.w, insetRect.h, 8)
		end)
	end
	
	self:loadSample(kAssetsSounds.menuSelect)
	self:loadSample(kAssetsSounds.menuSelectFail)
	self:loadSample(kAssetsSounds.menuAccept)
end

function WidgetEntriesMenu:_draw(frame)
	local entryHeight = (frame.h - 10) / #self.entries
	
	if self.painters.background ~= nil then
		self.painters.background:draw(frame)
	end
	
	for i, entry in pairs(self.entries) do
		local entryRect = Rect.with(frame, { h = entryHeight, y = frame.y + 5 + (entryHeight * (i - 1)) })
		entry:draw(entryRect)
	end
	
	self.frame = frame
end

function WidgetEntriesMenu:_update()
	self:filterInput(filter)
end

function WidgetEntriesMenu:_handleInput(input)
	if input.pressed & (playdate.kButtonA | playdate.kButtonB) ~= 0 then
		self:playSample(kAssetsSounds.menuAccept)
		
		self.signals.entrySelected(self.state)
	end
	
	if input.pressed & playdate.kButtonDown ~= 0 then
		if self.state < #self.entries then
			self:playSample(kAssetsSounds.menuSelect)
			self:setState(self.state + 1)
		else
			self:playSample(kAssetsSounds.menuSelectFail)
		end
	end
	
	if input.pressed & playdate.kButtonUp ~= 0 then
		if self.state > 1 then
			self:playSample(kAssetsSounds.menuSelect)
			self:setState(self.state - 1)
		else
			self:playSample(kAssetsSounds.menuSelectFail)
		end
	end
end

function WidgetEntriesMenu:_changeState(_, stateTo)
	for i, entry in ipairs(self.entries) do
		entry:setState(stateTo == i and entry.kStates.selected or entry.kStates.unselected)
		
		if self.frame ~= nil then
			gfx.sprite.addDirtyRect(self.frame.x, self.frame.y, self.frame.w, self.frame.h)
		end
	end
end

function WidgetEntriesMenu:unload()
	for i=1, #self.entries do
		self.children["entry"..i] = nil
		self.entries[i] = nil
	end
	
	self.entries = nil
end
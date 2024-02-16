import "settings/entry"

local gfx <const> = playdate.graphics
local _painterMenuCard = Painter.commonPainters.menuCard()

class("WidgetMenuSettings").extends(Widget)

WidgetMenuSettings.type = {
	options = 1,
	button = 2
}

function WidgetMenuSettings:_init(config)	
	self:supply(Widget.deps.state)
	self:supply(Widget.deps.input)
	self:supply(Widget.deps.samples)
	
	self.signals = {}
end

function WidgetMenuSettings:_load()
	self.painters = {}
	self.entries = {}
	
	self:setStateInitial(1)

	local function entryCallback(entry, key, value)
		if entry.config.type == WidgetMenuSettings.type.options then
			-- Option changed
			if value == "OFF" then
				value = 0
			end
			
			local settingsValue
			if tonumber(value) ~= nil then
				settingsValue = tonumber(value) / 10
			else
				settingsValue = value
			end
			
			Settings:setValue(key, settingsValue)
		elseif entry.config.type == WidgetMenuSettings.type.button then 
			-- Button pressed
			Settings:writeToFile()
			
			self:playSample(kAssetsSounds.menuAccept)
			
			self.signals.close()
		end
	end
	
	local function getEntryValue(entryType, key)
		if entryType == WidgetMenuSettings.type.options then
			local settingsValue = Settings:getValue(key)
			if settingsValue == 0 then
				return "OFF"
			elseif type(settingsValue) == "number" then
				return string.format("%d", settingsValue * 10)
			else
				return string.format("%s", settingsValue)
			end
		end
	end
	
	self:loadSample(kAssetsSounds.menuSelect, 0.6)
	self:loadSample(kAssetsSounds.menuSelectFail, 0.8)
	self:loadSample(kAssetsSounds.menuAccept, 0.7)
	
	for i, entryConfig in ipairs(self.config.entries) do
		
		local entry = Widget.new(WidgetMenuSettingsEntry, { 
			title = entryConfig.title, 
			isSelected = i == 1 and true or false, 
			type = entryConfig.type, 
			options = entryConfig.values, 
			loop = entryConfig.loopValues,
			value = getEntryValue(entryConfig.type, entryConfig.key)
		})
		
		entry:load()
		entry.signals.onChanged = function(value)
			entryCallback(entry, entryConfig.key, value)
		end
		
		table.insert(self.entries, entry)
		self.children["entry"..i] = entry
	end
end

function WidgetMenuSettings:_draw(frame, rect)
	local insetRect = Rect.inset(frame, 12, 6)
	_painterMenuCard:draw(insetRect)
	
	local entryHeight = 32
	local margin = 4
	for i, entry in ipairs(self.entries) do
		local entryRect = Rect.with(Rect.offset(Rect.inset(insetRect, 18, 26), 0, (entryHeight + margin) * (i - 1)), { h = entryHeight })
		entry:draw(entryRect)
	end
end

function WidgetMenuSettings:_update()
	self:passInput(self.entries[self.state], playdate.kButtonA | playdate.kButtonsLeftRight)
end

function WidgetMenuSettings:_handleInput(input)
	if input.pressed & playdate.kButtonUp ~= 0 then
		if self.state > 1 then
			self:setState(self.state - 1)
			
			self:playSample(kAssetsSounds.menuSelect)
		else
			self:playSample(kAssetsSounds.menuSelectFail)
		end
	end
	
	if input.pressed & playdate.kButtonDown ~= 0 then
		if self.state < #self.entries then
			self:setState(self.state + 1)
			
			self:playSample(kAssetsSounds.menuSelect)
		else
			self:playSample(kAssetsSounds.menuSelectFail)
		end
	end
end

function WidgetMenuSettings:_changeState(stateFrom, stateTo)
	self.entries[stateFrom]:setState(self.entries[stateFrom].kStateKeys.isSelected, self.entries[stateFrom].kStates.isSelected.unselected)
	self.entries[stateTo]:setState(self.entries[stateTo].kStateKeys.isSelected, self.entries[stateTo].kStates.isSelected.selected)
	
	gfx.sprite.addDirtyRect(0, 0, 400, 240)
end

function WidgetMenuSettings:_unload()
	self.painters = nil
	
	for _, child in pairs(self.children) do child:unload() end
end
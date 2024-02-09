import "settings/entry"

local gfx <const> = playdate.graphics
local _painterMenuCard = Painter.commonPainters.menuCard()

class("WidgetMenuSettings").extends(Widget)

WidgetMenuSettings.type = {
	options = 1,
	button = 2
}

function WidgetMenuSettings:init(config)
	self.config = config
	
	self:supply(Widget.deps.state)
	self:supply(Widget.deps.input)
	self:supply(Widget.deps.samples)
	
	self.signals = {}
end

function WidgetMenuSettings:_load()
	self.painters = {}
	self.entries = {}
	
	self:setStateInitial(1)

	self.painters.frame = Painter(function(rect)
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRoundRect(rect.x, rect.y, rect.w, rect.h, 8)
		
		gfx.setColor(gfx.kColorBlack)
		gfx.setDitherPattern(0.7, gfx.image.kDitherTypeDiagonalLine)
		gfx.fillRoundRect(rect.x, rect.y, rect.w, rect.h, 8)
		
		gfx.drawTextAligned("SETTINGS MENU", rect.x + rect.w / 2, rect.y + rect.h / 2, kTextAlignment.center)
	end)
	
	local function entryCallback(entry, key, value)
		if entry.config.type == WidgetMenuSettings.type.options then
			if value == "OFF" then
				value = 0
			end
			
			local settingsValue = tonumber(value) / 10
			
			-- Option changed
			Settings:setValue(key, settingsValue)
		elseif entry.config.type == WidgetMenuSettings.type.button then 
			-- Button pressed
			Settings:writeToFile()
			
			self:playSample(kAssetsSounds.menuAccept)
			
			self.signals.close()
		end
	end
	
	local function getEntryValue(type, key)
		if type == WidgetMenuSettings.type.options then
			local settingsValue = Settings:getValue(key)
			if settingsValue == 0 then
				return "OFF"
			else 
				return string.format("%d", settingsValue * 10)
			end
		end
	end
	
	self:loadSample(kAssetsSounds.menuSelect)
	self:loadSample(kAssetsSounds.menuSelectFail)
	self:loadSample(kAssetsSounds.menuAccept)
	
	for i, entryConfig in ipairs(self.config.entries) do
		
		local entry = Widget.new(WidgetMenuSettingsEntry, { 
			title = entryConfig.title, 
			isSelected = i == 1 and true or false, 
			type = entryConfig.type, 
			options = entryConfig.values, 
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
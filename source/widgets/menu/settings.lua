import "settings/entry"

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
	
	self.state = 1
	
	self.painters = {}
	self.entries = {}
	self.signals = {}
end

function WidgetMenuSettings:_load()
	self.painters.frame = Painter(function(rect)
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.fillRoundRect(rect.x, rect.y, rect.w, rect.h, 8)
		
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.setDitherPattern(0.7, playdate.graphics.image.kDitherTypeDiagonalLine)
		playdate.graphics.fillRoundRect(rect.x, rect.y, rect.w, rect.h, 8)
		
		playdate.graphics.drawTextAligned("SETTINGS MENU", rect.x + rect.w / 2, rect.y + rect.h / 2, kTextAlignment.center)
	end)
	
	local imageScrew1 = playdate.graphics.image.new(kAssetsImages.screw)
	
	local painterCardOutline = Painter(function(rect)
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.setDitherPattern(0.7, playdate.graphics.image.kDitherTypeDiagonalLine)
		playdate.graphics.fillRoundRect(rect.x, rect.y, rect.w, rect.h, 8)
		
		local rectBorder = Rect.inset(rect, 10, 14)
		local rectBorderInner = Rect.inset(rectBorder, 4, 6)
		local rectBorderInnerShadow = Rect.offset(rectBorderInner, -1, -1)
		
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.setDitherPattern(0.3, playdate.graphics.image.kDitherTypeDiagonalLine)
		playdate.graphics.setLineWidth(3)
		playdate.graphics.drawRoundRect(rectBorderInnerShadow.x, rectBorderInnerShadow.y, rectBorderInnerShadow.w, rectBorderInnerShadow.h, 6)
		
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.fillRoundRect(rectBorderInner.x, rectBorderInner.y, rectBorderInner.w, rectBorderInner.h, 6)
		
		local size = imageScrew1:getSize()
		imageScrew1:rotatedImage(90):draw(rect.x + 4, rect.y + 4)
		imageScrew1:rotatedImage(45):draw(rect.x + rect.w - size - 4, rect.y + 4)
		imageScrew1:draw(rect.x + 4, rect.y + rect.h - size - 4)
		imageScrew1:draw(rect.x + rect.w - size - 4, rect.y + rect.h - size - 4)
	end)
	
	self.painters.card = Painter(function(rect)
		-- Painter background
		
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.fillRoundRect(rect.x, rect.y, rect.w, rect.h, 8)
		
		painterCardOutline:draw(rect)
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
	self.painters.card:draw(insetRect)
	
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
	
	playdate.graphics.sprite.addDirtyRect(0, 0, 400, 240)
end
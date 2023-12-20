class("WidgetMenuSettingsEntry").extends(Widget)

-- Special chars: ◁ ◀ ▶ ▷

function WidgetMenuSettingsEntry:init(config)
	self.config = config
	
	self:supply(Widget.kDeps.keyValueState)
	self:supply(Widget.kDeps.input)
	
	local isSelected = config.isSelected == true and 1 or 2
	local value = config.value ~= nil and config.value or (config.options ~= nil) and config.options[1] or nil
	
	self:setStateInitial(
		{
			isSelected = { selected = 1, unselected = 2 },
			value = config.options
		},
		{ 
			isSelected = isSelected,
			value = value
		}
	)
	
	self.painters = {}
end

function WidgetMenuSettingsEntry:_load()
	self.painters.title = Painter(function(frame, state)
		if state.isSelected == true then
			local rectInset = Rect.inset(frame, 1, 1)
			playdate.graphics.setColor(playdate.graphics.kColorBlack)
			playdate.graphics.setLineWidth(2)
			playdate.graphics.drawRoundRect(rectInset.x, rectInset.y, rectInset.w, rectInset.h, 6)
		end
		
		local font = playdate.graphics.font.new(kAssetsFonts.twinbee2x)
		local fontHeight = font:getHeight()
		playdate.graphics.setFont(font)
		playdate.graphics.drawText(self.config.title, frame.x + 8, frame.y + (frame.h - fontHeight) / 2)
		playdate.graphics.setFont(playdate.graphics.font.new(kAssetsFonts.twinbee))
	end)
	
	if self.config.type == kDataTypeSettingsEntry.options then
		self.painters.value = Painter(function(frame, state)
			local font = playdate.graphics.font.new(kAssetsFonts.twinbee2x)
			local fontHeight = font:getHeight()
			playdate.graphics.setFont(font)
			playdate.graphics.drawTextAligned("◁ "..state.value.." ▷", frame.x + frame.w - 8, frame.y + (frame.h - fontHeight) / 2, kTextAlignment.right)
			playdate.graphics.setFont(playdate.graphics.font.new(kAssetsFonts.twinbee))
		end)
	end
end

function WidgetMenuSettingsEntry:_draw(frame, rect)
	self.painters.title:draw(frame, { isSelected = self.state.isSelected == self.kStates.isSelected.selected })
	
	if self.config.type == kDataTypeSettingsEntry.options then
		self.painters.value:draw(frame, { value = self.state.value })
	end
end

function WidgetMenuSettingsEntry:_update()
	self:handleInput()
end

function WidgetMenuSettingsEntry:_handleInput(input)
	if self.config.type == kDataTypeSettingsEntry.button then
		if input.pressed & playdate.kButtonA ~= 0 then
			print("Pressed ".. self.config.title)
		end
	end
	
	if self.config.type == kDataTypeSettingsEntry.options then
		if input.pressed & playdate.kButtonLeft ~= 0 then
			local index = table.indexOfElement(self.config.options, self.state.value)
			if index > 1 then
				self:setState(self.kStateKeys.value, self.kStates.value[index - 1])
				playdate.graphics.sprite.addDirtyRect(0, 0, 400, 240)
			end
		elseif input.pressed & playdate.kButtonRight ~= 0 then
			local index = table.indexOfElement(self.config.options, self.state.value)
			if index < #self.config.options then
				self:setState(self.kStateKeys.value, self.kStates.value[index + 1])
				playdate.graphics.sprite.addDirtyRect(0, 0, 400, 240)
			end
		end
	end
end
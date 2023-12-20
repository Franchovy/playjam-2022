class("WidgetMenuSettingsEntry").extends(Widget)

function WidgetMenuSettingsEntry:init(config)
	self.config = config
	
	self:supply(Widget.kDeps.state)
	local isSelected = config.isSelected == true and 1 or 2
	self:setStateInitial({ selected = 1, unselected = 2 }, isSelected)
	
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
end

function WidgetMenuSettingsEntry:_draw(frame, rect)
	self.painters.title:draw(frame, { isSelected = self.state == self.kStates.selected })
end

function WidgetMenuSettingsEntry:_update()
	
end
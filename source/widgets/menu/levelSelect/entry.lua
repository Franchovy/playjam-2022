import "utils/value"

class("LevelSelectEntry").extends(Widget)

function LevelSelectEntry:init(config)
	self.config = config
	
	self:supply(Widget.deps.state)
	
	local isSelected = config.isSelected == true
	self:setStateInitial({ selected = 1, unselected = 2}, isSelected and 1 or 2)
	
	self.images = {}
	self.painters = {}
end

function LevelSelectEntry:_load()
	self.images.title = playdate.graphics.imageWithText(self.config.text, 200, 70):scaledImage(2)
	
	self.painters.outline = Painter(function(rect, state)
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.setDitherPattern(0.2, playdate.graphics.image.kDitherTypeDiagonalLine)
		playdate.graphics.setLineWidth(1)
		playdate.graphics.drawRoundRect(rect.x, rect.y, rect.w, rect.h, 8)
		
		playdate.graphics.setDitherPattern(0.8, playdate.graphics.image.kDitherTypeScreen)
		playdate.graphics.fillRoundRect(rect.x, rect.y, rect.w, rect.h, 12)
	end)
	
	self.painters.outlineSelected = Painter(function(rect, state)
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.setLineWidth(3)
		playdate.graphics.setDitherPattern(0.2, playdate.graphics.image.kDitherTypeDiagonalLine)
		playdate.graphics.drawRoundRect(rect.x, rect.y, rect.w, rect.h, 12)
	end)
end

function LevelSelectEntry:_draw(rect)
	local outlineRect = Rect.inset(rect, 20, 0)
	
	self.images.title:draw(outlineRect.x + 10, outlineRect.y + 12)
	
	if self.state == self.kStates.unselected then
		if self.config.showOutline then	
			self.painters.outline:draw(outlineRect)
		end
	else
		self.painters.outlineSelected:draw(outlineRect)
	end
end

function LevelSelectEntry:_update()
	
end

function LevelSelectEntry:_changeState(stateFrom, stateTo)
	
end
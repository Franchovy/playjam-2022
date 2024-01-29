
local gfx <const> = playdate.graphics

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
	self.images.title = gfx.imageWithText(self.config.text, 200, 70):scaledImage(2)
	
	self.painters.outline = Painter(function(rect, state)
		gfx.setColor(gfx.kColorBlack)
		gfx.setDitherPattern(0.2, gfx.image.kDitherTypeDiagonalLine)
		gfx.setLineWidth(1)
		gfx.drawRoundRect(rect.x, rect.y, rect.w, rect.h, 8)
		
		gfx.setDitherPattern(0.8, gfx.image.kDitherTypeScreen)
		gfx.fillRoundRect(rect.x, rect.y, rect.w, rect.h, 12)
	end)
	
	self.painters.outlineSelected = Painter(function(rect, state)
		gfx.setColor(gfx.kColorBlack)
		gfx.setLineWidth(3)
		gfx.setDitherPattern(0.2, gfx.image.kDitherTypeDiagonalLine)
		gfx.drawRoundRect(rect.x, rect.y, rect.w, rect.h, 12)
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

function LevelSelectEntry:_unload()
	self.painters = nil
	self.images = nil
end
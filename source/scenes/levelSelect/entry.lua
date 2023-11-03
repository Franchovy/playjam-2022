import "utils/value"

class("LevelSelectEntry").extends(Widget)

function LevelSelectEntry:init(config)
	LevelSelect.super.init(self)
	
	self.state = {}
	self.state.selected = false
	
	self.images = {}
	self.painters = {}
	
	self.config = {}
	self.config.text = config.text
	self.config.showOutline = value.default(config.showOutline, true)
end

function LevelSelectEntry:load()
	--LevelSelect.super.load(self)
	
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

function LevelSelectEntry:draw(rect)
	LevelSelect.super.draw(self)
	
	local outlineRect = Rect.inset(rect, 20, 0)
	
	self.images.title:draw(outlineRect.x + 10, outlineRect.y + 12)
	
	if not self.state.selected then
		if self.config.showOutline then	
			self.painters.outline:draw(outlineRect)
		end
	else
		self.painters.outlineSelected:draw(outlineRect)
	end
end

function LevelSelectEntry:update()
	LevelSelect.super.update(self)
end

function LevelSelectEntry:setState(state)
	for k, v in pairs(state) do
		if self.state[k] ~= v then
			self:changeState(self.state, state)
			
			self.state[k] = v
		end
	end
end

function LevelSelectEntry:changeState(stateFrom, stateTo)
	
end
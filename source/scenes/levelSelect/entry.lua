class("LevelSelectEntry").extends(Widget)

function LevelSelectEntry:init(label, value)
	LevelSelect.super.init(self)
	
	self.label = label
	self.value = value
	
	self.state = {}
	self.state.selected = false
	
	self.images = {}
	self.painters = {}
end

function LevelSelectEntry:load()
	--LevelSelect.super.load(self)
	
	self.images.title = playdate.graphics.imageWithText(self.label, 200, 70):scaledImage(2)
	
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

function LevelSelectEntry:draw(position)
	LevelSelect.super.draw(self)
	
	self.images.title:draw(position.x + 20, position.y + 2)
	
	local outlineRect = Rect.inset(Rect.make(position.x, position.y, 190, 20), 0, -10)
	if not self.state.selected then
		self.painters.outline:draw(outlineRect)
	else
		self.painters.outlineSelected:draw(outlineRect)
	end
end

function LevelSelectEntry:update()
	LevelSelect.super.update(self)
end

function LevelSelectEntry:changeState(stateFrom, stateTo)
	
end
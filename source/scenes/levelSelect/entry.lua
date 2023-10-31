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
		playdate.graphics.setLineWidth(1)
		playdate.graphics.drawRoundRect(rect.x, rect.y, rect.w, rect.h, 4)
	end)
	
	self.painters.outlineSelected = Painter(function(rect, state)
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		--playdate.graphics.setDitherPattern(0.2, playdate.graphics.kDitherTypeScreen)
		playdate.graphics.setLineWidth(3)
		playdate.graphics.drawRoundRect(rect.x, rect.y, rect.w, rect.h, 4)
	end)
end

function LevelSelectEntry:draw(position)
	LevelSelect.super.draw(self)
	
	self.images.title:draw(position.x, position.y)
	
	if not self.state.selected then
		self.painters.outline:draw(Rect.make(position.x, position.y, 100, 20))
	else
		self.painters.outlineSelected:draw(position.x, position.y, 100, 20)
	end
end

function LevelSelectEntry:update()
	LevelSelect.super.update(self)
end

function LevelSelectEntry:changeState(stateFrom, stateTo)
	
end
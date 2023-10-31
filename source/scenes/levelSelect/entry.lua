class("LevelSelectEntry").extends(Widget)

function LevelSelectEntry:init(label, value)
	LevelSelect.super.init(self)
	
	self.label = label
	self.value = value
end

function LevelSelectEntry:load()
	--LevelSelect.super.load(self)
end

function LevelSelectEntry:draw(position)
	LevelSelect.super.draw(self)
	
	playdate.graphics.setColor(playdate.graphics.kColorWhite)
	local image = playdate.graphics.imageWithText(self.label, 200, 70):scaledImage(2)
	image:draw(position.x, position.y)
end

function LevelSelectEntry:update()
	LevelSelect.super.update(self)
end

function LevelSelectEntry:changeState(stateFrom, stateTo)
	
end
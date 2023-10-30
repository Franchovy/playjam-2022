class("LevelSelect").extends(Widget)

function LevelSelect:init()
	LevelSelect.super.init(self)
end

function LevelSelect:load()
	--LevelSelect.super.load(self)
end

function LevelSelect:draw()
	LevelSelect.super.draw(self)
	
	playdate.graphics.setColor(playdate.graphics.kColorWhite)
	playdate.graphics.fillRect(50, 50, 400 - 100, 240 - 100)
end

function LevelSelect:update()
	LevelSelect.super.update(self)
end

function LevelSelect:changeState(stateFrom, stateTo)
	
end
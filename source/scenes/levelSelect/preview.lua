class("LevelSelectPreview").extends(Widget)

function LevelSelectPreview:init()
	LevelSelect.super.init(self)
end

function LevelSelectPreview:load()
	--LevelSelectPreview.super.load(self)
end

function LevelSelectPreview:draw()
	LevelSelect.super.draw(self)
	
	playdate.graphics.setColor(playdate.graphics.kColorWhite)
	playdate.graphics.fillRect(50, 50, 400 - 100, 240 - 100)
end

function LevelSelectPreview:update()
	LevelSelect.super.update(self)
end

function LevelSelectPreview:changeState(stateFrom, stateTo)
	
end
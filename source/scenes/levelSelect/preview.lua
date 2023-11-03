class("LevelSelectPreview").extends(Widget)

function LevelSelectPreview:init()
	LevelSelect.super.init(self)
end

function LevelSelectPreview:load()
	--LevelSelectPreview.super.load(self)
end

function LevelSelectPreview:draw(position)
	LevelSelect.super.draw(self)
	
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.setDitherPattern(0.5, playdate.graphics.image.kDitherTypeDiagonalLine)
	playdate.graphics.fillRect(position.x, position.y, 140, 240)
end

function LevelSelectPreview:update()
	LevelSelect.super.update(self)
end

function LevelSelectPreview:changeState(stateFrom, stateTo)
	
end
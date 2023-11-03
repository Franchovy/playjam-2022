class("LevelSelectPreview").extends(Widget)

function LevelSelectPreview:init()
	LevelSelect.super.init(self)
end

function LevelSelectPreview:load()
	--LevelSelectPreview.super.load(self)
end

function LevelSelectPreview:draw(rect)
	LevelSelect.super.draw(self)
	
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.setDitherPattern(0.5, playdate.graphics.image.kDitherTypeDiagonalLine)
	playdate.graphics.fillRect(rect.x, rect.y, rect.w, rect.h)
end

function LevelSelectPreview:update()
	LevelSelect.super.update(self)
end

function LevelSelectPreview:changeState(stateFrom, stateTo)
	
end
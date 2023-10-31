import "levelSelect/entry"

class("LevelSelect").extends(Widget)

function LevelSelect:init()
	LevelSelect.super.init(self)
end

function LevelSelect:load()
	--LevelSelect.super.load(self)
	
	self.entries = {
		LevelSelectEntry("MOUNTAIN"),
		LevelSelectEntry("SPACE"),
		LevelSelectEntry("CITY"),
	}
	
	for _, entry in pairs(self.entries) do
		entry:load()
		self:addChild(entry)
	end
end

function LevelSelect:draw(position, children)
	playdate.graphics.setColor(playdate.graphics.kColorWhite)
	playdate.graphics.fillRect(position.x, position.y, 400, 240)
	
	for i, entry in ipairs(self.entries) do
 		entry:draw(Position.offset(position, 10, 20 + i * 45))
	end
end

function LevelSelect:update()
	LevelSelect.super.update(self)
end

function LevelSelect:changeState(stateFrom, stateTo)
	
end
import "levelSelect/entry"
import "levelSelect/preview"

class("LevelSelect").extends(Widget)

function LevelSelect:init()
	LevelSelect.super.init(self)
	
	self.state = {}
	self.painters = {}
	self.children = {}
	
	self.hidden = false
end

function LevelSelect:load()
	--LevelSelect.super.load(self)
	self.state.selection = 1
	
	self.children.entries = {
		LevelSelectEntry("MOUNTAIN"),
		LevelSelectEntry("SPACE"),
		LevelSelectEntry("CITY"),
	}
	
	self.children.preview = {
		LevelSelectPreview(),
		LevelSelectPreview(),
		LevelSelectPreview()
	}
	
	self.painters.background = Painter(function(rect)
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.fillRect(rect.x, rect.y, rect.w, rect.h)
	end)
	
	self.painters.card = Painter(function(rect)
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.setDitherPattern(0.1, playdate.graphics.image.kDitherTypeDiagonalLine)
		playdate.graphics.fillRect(rect.x + 5, rect.y, rect.w, rect.h)
		
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.fillRect(rect.x, rect.y, rect.w - 5, rect.h)
	end)
	
	for _, child in pairs(self.children.entries) do
		child:load()
	end
	
	for _, child in pairs(self.children.preview) do
		child:load()
	end
end

function LevelSelect:draw(rect)
	local width = 235
	
	self.painters.background:draw(rect)
	self.painters.card:draw(Rect.with(rect, { w = width }))
	
	for i, entry in ipairs(self.children.entries) do
 		entry:draw(Rect.make(rect.x + 10, rect.y + 20 + i * 45, width, 60))
	end
	
	if self.state.selection ~= nil then
		self.children.preview[self.state.selection]:draw(Rect.with(rect, { x = width, w = rect.w - width }))
	end
end

function LevelSelect:update()
	LevelSelect.super.update(self)
	
	if playdate.buttonJustPressed(playdate.kButtonA) then
		for i, entry in ipairs(self.children.entries) do
			 entry.state.selected = true
		end
	elseif playdate.buttonJustReleased(playdate.kButtonA) then
		for i, entry in ipairs(self.children.entries) do
			 entry.state.selected = false
		end
	end
end

function LevelSelect:changeState(stateFrom, stateTo)
	
end
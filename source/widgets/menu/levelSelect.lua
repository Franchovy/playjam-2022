import "levelSelect/entry"
import "levelSelect/preview"

class("LevelSelect").extends(Widget)

function LevelSelect:init()
	self:supply(Widget.kDeps.state)
	self:supply(Widget.kDeps.children)
	
	self:setStateInitial({1, 2, 3, 4}, 1)
	
	self.painters = {}
	self.samples = {}
	
	self.hidden = false
end

function LevelSelect:load()
	self.samples.select = playdate.sound.sampleplayer.new(kAssetsSounds.menuSelect)
	self.samples.selectFail = playdate.sound.sampleplayer.new(kAssetsSounds.menuSelectFail)
	
	self.children.entries = {
		LevelSelectEntry({ text = "MOUNTAIN" }),
		LevelSelectEntry({ text = "SPACE" }),
		LevelSelectEntry({ text = "CITY" }),
		LevelSelectEntry({ text = "SETTINGS", showOutline = false })
	}
	
	self.children.preview = LevelSelectPreview()
	
	self.painters.background = Painter(function(rect)
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.fillRect(rect.x, rect.y, rect.w, rect.h)
	end)
	
	local painterCardOutline = Painter(function(rect)
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.setDitherPattern(0.7, playdate.graphics.image.kDitherTypeDiagonalLine)
		playdate.graphics.fillRect(rect.x, rect.y, rect.w, rect.h)
		
		local rectInset = Rect.inset(rect, 10, 14)
		
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.setDitherPattern(0.3, playdate.graphics.image.kDitherTypeDiagonalLine)
		playdate.graphics.setLineWidth(3)
		playdate.graphics.drawRoundRect(rectInset.x - 4, rectInset.y - 1, rectInset.w, rectInset.h, 6)
		
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.fillRoundRect(rectInset.x - 3, rectInset.y, rectInset.w, rectInset.h, 6)
	end)
	
	self.painters.card = Painter(function(rect)
		-- Painter background
		
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.setDitherPattern(0.1, playdate.graphics.image.kDitherTypeDiagonalLine)
		playdate.graphics.fillRect(rect.x + 5, rect.y, rect.w, rect.h)
		
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.fillRect(rect.x, rect.y, rect.w - 5, rect.h)
		
		painterCardOutline:draw(rect)
	end)
	
	for _, child in pairs(self.children.entries) do
		child:load()
	end
	
	self.children.preview:load()
end

function LevelSelect:draw(rect)
	local width = 220
	
	--self.painters.background:draw(rect)
	self.painters.card:draw(Rect.with(rect, { w = width }))
	
	for i, entry in ipairs(self.children.entries) do
 		entry:draw(Rect.make(rect.x - 5, rect.y + i * 45 - 25, width, 40))
	end
	
	self.children.preview:draw(Rect.with(rect, { x = width, w = rect.w - width }))
end

function LevelSelect:update()
	-- TODO: Add Crank
	local scrollUp = playdate.buttonJustPressed(playdate.kButtonUp)
	local scrollDown = playdate.buttonJustPressed(playdate.kButtonDown)
	
	if scrollUp then
		if self.state > 1 then
			self:setState(self.state - 1)
			
			self.samples.select:play()
		else
			self.samples.selectFail:play()
		end
	end
	
	if scrollDown then
		if self.state < #self.children.entries then
			self:setState(self.state + 1)
			
			self.samples.select:play()
		else
			self.samples.selectFail:play()
		end
	end
	
	for i, entry in ipairs(self.children.entries) do
		if i == self.state then
			entry:setState({ selected = true })
		elseif entry.state.selected == true then
			entry:setState({ selected = false })
		end
	end
end

function LevelSelect:changeState(_, _)
	
end

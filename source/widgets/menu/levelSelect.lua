import "levelSelect/entry"
import "levelSelect/preview"

class("WidgetLevelSelect").extends(Widget)

WidgetLevelSelect.kMenuActionType = {
	play = "play",
	menu = "menu"
}

function WidgetLevelSelect:init(config)
	self:supply(Widget.kDeps.state)
	self:supply(Widget.kDeps.children)
	
	self:setStateInitial({1, 2, 3, 4}, 1)
	
	self.painters = {}
	self.images = {}
	
	self.samples = {}
	
	self.selectCallback = config.menuSelectCallback
	
	-- TODO: Feed these from higher up. Same with settings
	self.kLevels = {
		{
			title = "MOUNTAIN",
			menuImagePath = kAssetsImages.menuMountain,
			levelFileName = "1_mountain"
		},
		{
			title = "SPACE",
			menuImagePath = kAssetsImages.menuSpace,
			levelFileName = "2_space"
		},
		{
			title = "CITY",
			menuImagePath = kAssetsImages.menuCity,
			levelFileName = "3_city"
		}
	}

end

function WidgetLevelSelect:_load()
	self.samples.select = playdate.sound.sampleplayer.new(kAssetsSounds.menuSelect)
	self.samples.selectFail = playdate.sound.sampleplayer.new(kAssetsSounds.menuSelectFail)
	
	self.entries = {}
	self.previews = {}
	
	for i, v in ipairs(self.kLevels) do
		local entry = Widget.new(LevelSelectEntry, { text = v.title })
		table.insert(self.entries, entry)
		self.children["entry"..i] = entry
		
		local preview = Widget.new(LevelSelectPreview, { 
			name = v.title,
			image = playdate.graphics.image.new(v.menuImagePath),
			highscore = nil
		})
		table.insert(self.previews, preview)
		self.children["preview"..i] = preview
	end
	
	local entrySettings = Widget.new(LevelSelectEntry, { text = "SETTINGS", showOutline = false })
	table.insert(self.entries, entrySettings)
	self.children.entrySettings = entrySettings
	
	self.images.screw1 = playdate.graphics.image.new(kAssetsImages.screw)
	self.images.screw2 = playdate.graphics.image.new(kAssetsImages.screw):rotatedImage(45)
	self.images.screw3 = playdate.graphics.image.new(kAssetsImages.screw):rotatedImage(90)
	
	self.painters.background = Painter(function(rect)
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.fillRect(rect.x, rect.y, rect.w, rect.h)
	end)
	
	local painterCardOutline = Painter(function(rect)
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.setDitherPattern(0.7, playdate.graphics.image.kDitherTypeDiagonalLine)
		playdate.graphics.fillRoundRect(rect.x, rect.y, rect.w, rect.h, 8)
		
		local rectInset = Rect.inset(rect, 10, 14)
		
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.setDitherPattern(0.3, playdate.graphics.image.kDitherTypeDiagonalLine)
		playdate.graphics.setLineWidth(3)
		playdate.graphics.drawRoundRect(rectInset.x - 4, rectInset.y - 1, rectInset.w, rectInset.h, 6)
		
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.fillRoundRect(rectInset.x - 3, rectInset.y, rectInset.w, rectInset.h, 6)
		
		local size = self.images.screw1:getSize()
		self.images.screw2:draw(rect.x + 4, rect.y + 4)
		self.images.screw3:draw(rect.x + rect.w - size - 4, rect.y + 4)
		self.images.screw1:draw(rect.x + 4, rect.y + rect.h - size - 4)
		self.images.screw2:draw(rect.x + rect.w - size - 4, rect.y + rect.h - size - 4)
	end)
	
	self.painters.card = Painter(function(rect)
		-- Painter background
		
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.setDitherPattern(0.1, playdate.graphics.image.kDitherTypeDiagonalLine)
		playdate.graphics.fillRoundRect(rect.x, rect.y, rect.w, rect.h, 8)
		
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.fillRoundRect(rect.x, rect.y, rect.w, rect.h, 8)
		
		painterCardOutline:draw(rect)
	end)
	
	for _, child in pairs(self.children) do
		child:load()
	end
end

function WidgetLevelSelect:_draw(rect)
	local width = 220
	
	self.painters.card:draw(Rect.offset(Rect.with(rect, { w = width }), -self.animators.card:currentValue(), 0))
	
	for i, entry in ipairs(self.entries) do
 		entry:draw(Rect.make(rect.x - 5 - self.animators.card:currentValue(), rect.y + i * 45 - 25, width, 40))
	end
	
	if self.previews[self.state] ~= nil then
		self.previews[self.state]:draw(Rect.with(rect, { x = width, w = rect.w - width }))
	end
end

function WidgetLevelSelect:_update()
	if self.animators == nil then
		self.animators = {}
		self.animators.card = playdate.graphics.animator.new(800, 240, 0, playdate.easingFunctions.outExpo)
	end
	
	if self.animators.card:currentValue() < 100 then
		local selectButtonPressed = playdate.buttonJustPressed(playdate.kButtonA)
		if selectButtonPressed then
			local index = self.state
			if index <= #self.kLevels then
				-- Load level
				self.selectCallback({ type = WidgetLevelSelect.kMenuActionType.play, path = self.kLevels[index].levelFileName })
			elseif index == 4 then
				-- Settings
				self.selectCallback({ type = WidgetLevelSelect.kMenuActionType.menu, name = "settings" })
			end
		end
	end
	
	local scrollUp = playdate.buttonJustPressed(playdate.kButtonUp)
	local scrollDown = playdate.buttonJustPressed(playdate.kButtonDown)
	
	if scrollUp then
		if self.state > 1 then
			self:setState(self.state - 1)
			
			self.samples.select:play()
		else
			self.samples.selectFail:play()
			self.animators.card = playdate.graphics.animator.new(50, 0, 16, playdate.easingFunctions.outInBack)
			self.animators.card.reverses = true
		end
	end
	
	if scrollDown then
		if self.state < #self.entries then
			self:setState(self.state + 1)
			
			self.samples.select:play()
		else
			self.samples.selectFail:play()
			self.animators.card = playdate.graphics.animator.new(50, 0, 16, playdate.easingFunctions.outInBack)
			self.animators.card.reverses = true
		end
	end
	
	for i, entry in ipairs(self.entries) do
		if i == self.state then
			entry:setState({ selected = true })
		elseif entry.state.selected == true then
			entry:setState({ selected = false })
		end
	end
end

function WidgetLevelSelect:changeState(_, stateTo)
	
end

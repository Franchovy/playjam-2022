import "levelSelect/entry"
import "levelSelect/preview"
import "levelSelect/previewImage"

local easing <const> = playdate.easingFunctions
local gfx <const> = playdate.graphics

class("WidgetLevelSelect").extends(Widget)

WidgetLevelSelect.kMenuActionType = {
	play = "play",
	menu = "menu"
}

function WidgetLevelSelect:init(config)
	self.config = config
	
	self:supply(Widget.deps.state)
	self:supply(Widget.deps.animations)
	self:supply(Widget.deps.samples)
	self:supply(Widget.deps.input)
	
	self:setAnimations({
		intro = 1,
		error = 2,
		outro = 3
	})
	
	self:setStateInitial({1, 2, 3, 4}, 1)
	
	self.painters = {}
	self.images = {}
	
	self.signals = {}
end

function WidgetLevelSelect:_load()
	self:loadSample(kAssetsSounds.menuSelect)
	self:loadSample(kAssetsSounds.menuSelectFail)
	
	self.entries = {}
	self.previews = {}
	
	for i, level in ipairs(self.config.levels) do
		local entry = Widget.new(LevelSelectEntry, { text = level.title, isSelected = i == 1, showOutline = true })
		table.insert(self.entries, entry)
		self.children["entry"..i] = entry
		
		local score = self.config.scores[level.title]
		local preview = Widget.new(LevelSelectPreview, {
			title = level.title,
			imagePath = level.menuImagePath,
			score = score
		})
		table.insert(self.previews, preview)
		self.children["preview"..i] = preview
	end
	
	local entrySettings = Widget.new(LevelSelectEntry, { text = "SETTINGS", showOutline = false })
	table.insert(self.entries, entrySettings)
	self.children.entrySettings = entrySettings
	
	local previewSettings = Widget.new(LevelSelectPreviewImage, { path = kAssetsImages.menuSettings, title = "SETTINGS" })
	table.insert(self.previews, previewSettings)
	self.children["preview"..4] = previewSettings
	
	self.images.screw1 = gfx.image.new(kAssetsImages.screw)
	self.images.screw2 = gfx.image.new(kAssetsImages.screw):rotatedImage(45)
	self.images.screw3 = gfx.image.new(kAssetsImages.screw):rotatedImage(90)
	
	local painterCardOutline = Painter(function(rect)
		gfx.setColor(gfx.kColorBlack)
		gfx.setDitherPattern(0.7, gfx.image.kDitherTypeDiagonalLine)
		gfx.fillRoundRect(rect.x, rect.y, rect.w, rect.h, 8)
		
		local rectInset = Rect.inset(rect, 10, 14)
		
		gfx.setColor(gfx.kColorBlack)
		gfx.setDitherPattern(0.3, gfx.image.kDitherTypeDiagonalLine)
		gfx.setLineWidth(3)
		gfx.drawRoundRect(rectInset.x - 4, rectInset.y - 1, rectInset.w, rectInset.h, 6)
		
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRoundRect(rectInset.x - 3, rectInset.y, rectInset.w, rectInset.h, 6)
		
		local size = self.images.screw1:getSize()
		self.images.screw2:draw(rect.x + 4, rect.y + 4)
		self.images.screw3:draw(rect.x + rect.w - size - 4, rect.y + 4)
		self.images.screw1:draw(rect.x + 4, rect.y + rect.h - size - 4)
		self.images.screw2:draw(rect.x + rect.w - size - 4, rect.y + rect.h - size - 4)
	end)
	
	self.painters.card = Painter(function(rect)
		-- Painter background
		
		gfx.setColor(gfx.kColorBlack)
		gfx.setDitherPattern(0.1, gfx.image.kDitherTypeDiagonalLine)
		gfx.fillRoundRect(rect.x, rect.y, rect.w, rect.h, 8)
		
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRoundRect(rect.x, rect.y, rect.w, rect.h, 8)
		
		painterCardOutline:draw(rect)
	end)
	
	for _, child in pairs(self.children) do
		child:load()
	end
end

function WidgetLevelSelect:_draw(rect)
	local cardWidth = 220
	local xOffset = self:getAnimatorValue(self.animators.card)
	
	self.painters.card:draw(Rect.offset(Rect.with(rect, { w = cardWidth }), xOffset, 0))
	
	for i, entry in ipairs(self.entries) do
 		entry:draw(Rect.make(rect.x - 5 + xOffset, rect.y + i * 45 - 25, cardWidth, 40))
	end
	
	local previewX = self:getAnimatorValue(self.animators.preview) + cardWidth
	
	if self.previews[self.state] ~= nil then
		self.previews[self.state]:draw(Rect.with(rect, { x = previewX, w = rect.w - cardWidth }))
	end
end

function WidgetLevelSelect:_update()
	if self.wasAnimating == true then
		gfx.sprite.addDirtyRect(0, 0, 400, 240)
	end
	
	self.wasAnimating = self:isAnimating()
end

function WidgetLevelSelect:_handleInput(input)
	if input.pressed & playdate.kButtonA ~= 0 then
		local index = self.state
		if index <= #self.config.levels then
			-- Load level
			self.signals.select({ type = WidgetLevelSelect.kMenuActionType.play, level = self.config.levels[index] })
		elseif index == 4 then
			-- Settings
			self.signals.select({ type = WidgetLevelSelect.kMenuActionType.menu, name = "settings" })
		end
	end
	
	if input.pressed & playdate.kButtonUp ~= 0 then
		if self.state > 1 then
			self:playSample(kAssetsSounds.menuSelect)
			
			self:setState(self.state - 1)
		else
			self:playSample(kAssetsSounds.menuSelectFail)
			
			self:animate(self.kAnimations.error)
		end
	end
	
	if input.pressed & playdate.kButtonDown ~= 0 then
		if self.state < #self.entries then
			self:playSample(kAssetsSounds.menuSelect)
			
			self:setState(self.state + 1)
		else
			self:playSample(kAssetsSounds.menuSelectFail)
			
			self:animate(self.kAnimations.error)
		end
	end
end

function WidgetLevelSelect:_animate(animation, queueFinishedCallback)
	if animation == self.kAnimations.intro then
		self.animators.card = gfx.animator.new(800, -240, 0, easing.outExpo)
		self.animators.preview = gfx.animator.new(600, 240, 0, easing.inCubic)
		
		queueFinishedCallback(800)
	elseif animation == self.kAnimations.error then
		self.animators.card = gfx.animator.new(50, 0, -16, easing.outInBack)
		self.animators.card.reverses = true
		
		queueFinishedCallback(50)
	elseif animation == self.kAnimations.outro then
		self.animators.card = gfx.animator.new(800, 0, -240, easing.outExpo)
		self.animators.preview = gfx.animator.new(600, 0, 240, easing.inCubic)

		queueFinishedCallback(800)
	end
end

function WidgetLevelSelect:_changeState(_, stateTo)
	for i, entry in ipairs(self.entries) do
		if i == stateTo then
			entry:setState(entry.kStates.selected)
		elseif entry.state == entry.kStates.selected then
			entry:setState(entry.kStates.unselected)
		end
	end
	
	gfx.sprite.addDirtyRect(0, 0, 400, 240)
end

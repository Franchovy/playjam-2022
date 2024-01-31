import "levelSelect/entry"
import "levelSelect/preview"
import "levelSelect/previewImage"
import "widgets/common/painters"

local easing <const> = playdate.easingFunctions
local gfx <const> = playdate.graphics
local disp <const> = playdate.display
local geo <const> = playdate.geometry

local _tOffset <const> = geo.rect.tOffset
local _assign <const> = geo.rect.assign
local _tSet <const> = geo.rect.tSet
local _create <const> = table.create

local cardWidth <const> = 220

local _painterMenuCard = Painter.commonPainters.menuCard

class("WidgetLevelSelect").extends(Widget)

WidgetLevelSelect.kMenuActionType = {
	play = "play",
	menu = "menu"
}

function WidgetLevelSelect:init(config)
	WidgetLevelSelect.super.init(self)
	
	self.config = config
	
	self:supply(Widget.deps.state)
	self:supply(Widget.deps.animations)
	self:supply(Widget.deps.samples)
	self:supply(Widget.deps.input)
	self:supply(Widget.deps.frame)
	
	self:setFrame(disp.getRect())
	
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
	
	for _, child in pairs(self.children) do
		child:load()
	end
	
	local _rects = self.rects
	local _frame = self.frame
	
	_rects.entry = _create(#self.entries, 0)
	for i, entry in ipairs(self.entries) do
		_rects.entry[i] = _assign(_rects.entry[i], _frame.x - 5, _frame.y + i * 39 - 19, cardWidth, 40)
		entry:setFrame(_rects.entry[i])
	end
end

function WidgetLevelSelect:_draw(frame, rect)
	if self.hasPerformedLayout ~= true then
		return
	end
	
	local _rects = self.rects
	
	_painterMenuCard:draw(_rects.card)
	
	for i, entry in ipairs(self.entries) do
 		entry:draw()
	end
	
	if self.previews[self.state] ~= nil then
		self.previews[self.state]:draw(_rects.preview)
	end
end

function WidgetLevelSelect:_update()
	if self:hasAnimationChanged() == true then
		local xOffset = self:getAnimatorValue(self.animators.card)
		local previewX = self:getAnimatorValue(self.animators.preview) + cardWidth
		
		local _rects = self.rects
		local _frame = self.frame
		
		_rects.card = _tOffset(_tSet(_assign(_rects.card, _frame), nil, nil, cardWidth), xOffset, 0)
		
		for i, entry in ipairs(self.entries) do
			_rects.entry[i] = _tSet(_rects.entry[i], _frame.x - 5 + xOffset)
			
			entry:setFrame(_rects.entry[i])
			entry:setNeedsLayout()
		end
		
		_rects.preview = _tSet(_assign(_rects.preview, _frame), previewX, nil, _frame.w - cardWidth)

		gfx.sprite.addDirtyRect(0, 0, 400, 240)
		self.hasPerformedLayout = true
	end
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

function WidgetLevelSelect:_unload()
	self.samples = nil
	self.painters = nil
	self.animators = nil
	self.images = nil
	
	for _, child in pairs(self.children) do child:unload() end
	self.children = nil
end
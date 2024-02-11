import "widgets/common/painters"
import "previewMenu/levelPreview"
import "previewMenu/entry"
import "previewMenu/previewImage"

local easing <const> = playdate.easingFunctions
local gfx <const> = playdate.graphics
local disp <const> = playdate.display
local geo <const> = playdate.geometry

local _tOffset <const> = geo.rect.tOffset
local _assign <const> = geo.rect.assign
local _tSet <const> = geo.rect.tSet
local _create <const> = table.create

local cardWidth <const> = 220

local _painterMenuCard = Painter.commonPainters.menuCard()

class("WidgetPreviewMenu").extends(Widget)

WidgetPreviewMenu.kMenuActionType = {
	play = "play",
	menu = "menu"
}

function WidgetPreviewMenu:_init()
	self:supply(Widget.deps.state)
	self:supply(Widget.deps.animations)
	self:supply(Widget.deps.samples)
	self:supply(Widget.deps.input)
	self:supply(Widget.deps.frame, { needsLayout = true })
	
	self:setFrame(disp.getRect())
	
	self:setAnimations({
		intro = 1,
		error = 2,
		outro = 3
	})
	
	self.painters = {}
	self.images = {}
	self.signals = {}
end

function WidgetPreviewMenu:_load()
	local numStates = #self.config.entries
	
	if self.config.enableBackButton == true then
		numStates += 1
	end
	
	self:setStateInitial(1, numStates)
	
	self:loadSample(kAssetsSounds.menuSelect, 0.6)
	self:loadSample(kAssetsSounds.menuSelectFail, 0.8)
	self:loadSample(kAssetsSounds.menuAccept, 0.7)
	
	self.entries = {}
	self.previews = {}
	
	-- entry: { class, config, preview: { class, config } }
	
	for i, entry in ipairs(self.config.entries) do
		if i == 1 then
			entry.config.isSelected = true
		end
		
		local widgetEntry = Widget.new(entry.class, entry.config)
		table.insert(self.entries, widgetEntry)
		self.children["entry"..i] = widgetEntry
	
		local preview = entry.preview
		local widgetPreview = Widget.new(preview.class, preview.config)
		table.insert(self.previews, widgetPreview)
		self.children["preview"..i] = widgetPreview
	end
	
	if self.config.enableBackButton == true then
		local widgetEntry = Widget.new(WidgetMenuEntry, { title = "BACK" })
		table.insert(self.entries, widgetEntry)
		self.children["entry"..#self.kStates] = widgetEntry
	end
	
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
	
	self.animators.card = gfx.animator.new(0, 800, 800)
end

function WidgetPreviewMenu:_draw(frame, rect)
	local _rects = self.rects
	
	_painterMenuCard:draw(_rects.card)
	
	for i, entry in ipairs(self.entries) do
		 entry:draw()
	end
	
	if self.previews[self.state] ~= nil then
		self.previews[self.state]:draw(_rects.preview)
	end
end

function WidgetPreviewMenu:_update()
	if self:hasAnimationChanged() == true then
		self:performLayout()

		gfx.sprite.addDirtyRect(0, 0, 400, 240)
	end
end

function WidgetPreviewMenu:_performLayout()
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
end

function WidgetPreviewMenu:_handleInput(input)
	if input.pressed & playdate.kButtonA ~= 0 then
		local success
		
		if self.config.enableBackButton == true and self.state == #self.kStates then
			success = self.signals.entrySelected(nil)
		else
			success = self.signals.entrySelected(self.entries[self.state])
		end
		
		if success == true then
			self:playSample(kAssetsSounds.menuAccept)
		elseif success == false then
			self:playSample(kAssetsSounds.menuSelectFail)
			
			self:animate(self.kAnimations.error)
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

function WidgetPreviewMenu:_animate(animation, queueFinishedCallback)
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

function WidgetPreviewMenu:_changeState(_, stateTo)
	for i, entry in ipairs(self.entries) do
		if i == stateTo then
			entry:setState(entry.kStates.selected)
		elseif entry.state == entry.kStates.selected then
			entry:setState(entry.kStates.unselected)
		end
	end
	
	gfx.sprite.addDirtyRect(0, 0, 400, 240)
end

function WidgetPreviewMenu:_unload()
	self.painters = nil
	self.images = nil
	
	for _, child in pairs(self.children) do child:unload() end
end
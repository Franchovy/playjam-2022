import "utils/rect"
import "utils/position"
import "menu/levelSelect"
import "menu/title"

class("WidgetMenu").extends(Widget)

function WidgetMenu:init()
	self:supply(Widget.kDeps.children)
	self:supply(Widget.kDeps.state)
	self:supply(Widget.kDeps.samples)
	
	self:setStateInitial({default = 1, menu = 2}, 1)
	
	self.index = 0
	self.tick = 0
end

function WidgetMenu:_load()
	self:loadSample(kAssetsSounds.click)
	
	local menuSelectCallback = function(args)
		print("Selected menu options:")
		printTable(args)
	end
	
	self.children.title = Widget.new(WidgetTitle)
	self.children.title:load()
	
	self.children.levelSelect = Widget.new(WidgetLevelSelect, { menuSelectCallback = menuSelectCallback })
	self.children.levelSelect:load()
	self.children.levelSelect:setIsHidden(true)
	
	self.children.title:animate(WidgetLevelSelect.kAnimations.animateIn)
end

function WidgetMenu:_draw(rect)
	-- Paint children
	
	self.children.title:draw(rect)
	self.children.levelSelect:draw(rect)
end

function WidgetMenu:_update()
	self.index += 2
	
	if self.index % 40 > 32 then
		self.tick = self.tick == 0 and 1 or 0
	end
	
	if playdate.buttonIsPressed(playdate.kButtonA) then
		self.tick = 0
		self:setState(self.kStates.menu)
		
		
		self.children.title:animate(WidgetLevelSelect.kAnimations.animateOut)
		
		playdate.timer.performAfterDelay(1800, function()
			self.children.title:setIsHidden(true)
			self.children.levelSelect:setIsHidden(false)
		end)
		
	end
	
	if playdate.buttonIsPressed(playdate.kButtonB) then
		self.tick = 0
		self:setState(self.kStates.default)
		self.children.title:setIsHidden(false)
		
		self.children.levelSelect:setIsHidden(true)
		
		self.children.title:animate(WidgetLevelSelect.kAnimations.animateBackIn)
	end
end

function WidgetMenu:changeState(stateFrom, stateTo)
	if stateFrom == self.kStates.default and stateTo == self.kStates.menu then
		self:playSample(kAssetsSounds.click)
		
		if self.children.levelSelect == nil then
			self.children.levelSelect = Widget.new(LevelSelect)
			self.children.levelSelect:load()
		end
	end
	
	if stateFrom == self.kStates.menu and stateTo == self.kStates.default then
		self:playSample(kAssetsSounds.click)
	end
end
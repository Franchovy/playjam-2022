import "utils/rect"
import "utils/position"
import "menu/levelSelect"
import "menu/title"

class("WidgetMenu").extends(Widget)

function WidgetMenu:init(config)	
	self.config = config
	
	self:supply(Widget.kDeps.children)
	self:supply(Widget.kDeps.state)
	self:supply(Widget.kDeps.samples)
	
	self.painters = {}
	self.signals = {}
	
	self:setStateInitial({default = 1, menu = 2}, 1)
	
	self.index = 0
	self.tick = 0
	
	self.transitioningOut = true
end

function WidgetMenu:_load()
	self:loadSample(kAssetsSounds.menuAccept)
	self:loadSample(kAssetsSounds.intro)
	
	self.painters.background = PainterBackground()
	
	self.children.title = Widget.new(WidgetTitle)
	self.children.title:load()
	
	self.children.levelSelect = Widget.new(WidgetLevelSelect, { levels = self.config.levels, scores = self.config.scores })
	self.children.levelSelect:load()
	self.children.levelSelect:setVisible(false)
	
	self.children.levelSelect.signals.select = function(args)
		if args.type == WidgetLevelSelect.kMenuActionType.play and (args.level ~= nil) then
			self:playSample(kAssetsSounds.menuAccept)
			
			self.signals.play(args.level)
		end
	end
	
	self.children.title:animate(self.children.title.kAnimations.onFirstOpen)
	
	playdate.timer.performAfterDelay(600, function()
		self:playSample(kAssetsSounds.intro)
	end)
end

function WidgetMenu:_draw(rect)
	-- Paint children
	
	self.painters.background:draw(rect)
	
	self.children.title:draw(rect)
	self.children.levelSelect:draw(rect)
end

function WidgetMenu:_update()
	self.index += 2
	
	if self.index % 40 > 32 then
		self.tick = self.tick == 0 and 1 or 0
	end
	
	if playdate.buttonJustPressed(playdate.kButtonA) then
		self.tick = 0
		self:setState(self.kStates.menu)
	end
	
	if playdate.buttonJustPressed(playdate.kButtonB) then
		self.tick = 0
		self:setState(self.kStates.default)
	end
end

function WidgetMenu:changeState(stateFrom, stateTo)
	if stateFrom == self.kStates.default and stateTo == self.kStates.menu then
		self:playSample(kAssetsSounds.menuAccept)
		
		if self.children.levelSelect == nil then
			self.children.levelSelect = Widget.new(LevelSelect)
			self.children.levelSelect:load()
		end
		
		self.children.title:animate(self.children.title.kAnimations.toLevelSelect, function(animationChanged)
			if not animationChanged then
				self.children.title:setVisible(false)
				self.children.levelSelect:setVisible(true)
				
				self.children.levelSelect:animate(self.children.levelSelect.kAnimations.open)
			end
		end)
	end
	
	if stateFrom == self.kStates.menu and stateTo == self.kStates.default then
		self:playSample(kAssetsSounds.menuAccept)
		
		self.children.title:setVisible(true)
		self.children.levelSelect:setVisible(false)
		
		self.children.title:animate(self.children.title.kAnimations.fromLevelSelect)
	end
end

function WidgetMenu:_unload()
	self.samples = {}
	self.painters.background = nil
	self.children.title = nil
	self.children.levelSelect = nil
	self.children.title = nil
end
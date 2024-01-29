import "utils/position"
import "utils/rect"
import "menu/levelSelect"
import "menu/title"
import "menu/settings"

local gfx <const> = playdate.graphics
local timer <const> = playdate.timer
local disp <const> = playdate.display

class("WidgetMenu").extends(Widget)

function WidgetMenu:init(config)
	WidgetMenu.super.init(self)
	
	self.config = config
	
	self:supply(Widget.deps.state)
	self:supply(Widget.deps.samples)
	self:supply(Widget.deps.input)
	self:supply(Widget.deps.fileplayer)
	self:supply(Widget.deps.frame)
	
	self:setFrame(disp.getRect())
	
	self.painters = {}
	self.signals = {}
	
	self:setStateInitial({default = 1, menu = 2, subMenu = 3}, 1)
	
	self.index = 0
	self.tick = 0
	
	self.transitioningOut = true
end

function WidgetMenu:_load()
	self:loadSample(kAssetsSounds.menuAccept)
	self:loadSample(kAssetsSounds.intro)
	
	self.painters.background = Painter(function(rect)
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRect(0, 0, rect.w, rect.h)
		
		gfx.setColor(gfx.kColorBlack)
		gfx.setDitherPattern(0.1, gfx.image.kDitherTypeBayer4x4)
		gfx.fillRect(0, 0, rect.w, rect.h)
	end)
	
	self.children.title = Widget.new(WidgetTitle)
	self.children.title:load()
	
	self.children.levelSelect = Widget.new(WidgetLevelSelect, { levels = self.config.levels, scores = self.config.scores })
	self.children.levelSelect:load()
	self.children.levelSelect:setVisible(false)
	
	self.children.levelSelect.signals.select = function(args)
		if args.type == WidgetLevelSelect.kMenuActionType.play and (args.level ~= nil) then
			
			if AppConfig.enableBackgroundMusic == true then
				self:stopFilePlayer()
			end
			
			self:playSample(kAssetsSounds.menuAccept)
			
			self.signals.play(args.level)
		elseif args.type == WidgetLevelSelect.kMenuActionType.menu then
			self:setState(self.kStates.subMenu)
		end
	end
	
	local valuesMenuEntriesTypeOptions = {"OFF","1","2","3","4","5","6","7","8","9","10"}
	local dataSettingsMenuEntries = {
		{
			title = "SFX VOLUME",
			type = WidgetMenuSettings.type.options,
			values = valuesMenuEntriesTypeOptions,
			key = kSettingsKeys.sfxVolume
		},
		{
			title = "MUSIC VOLUME",
			type = WidgetMenuSettings.type.options,
			values = valuesMenuEntriesTypeOptions,
			key = kSettingsKeys.musicVolume
		},
		{
			title = "BACK",
			type = WidgetMenuSettings.type.button
		}
	}
	self.children.menuSettings = Widget.new(WidgetMenuSettings, { entries = dataSettingsMenuEntries })
	self.children.menuSettings:load()
	self.children.menuSettings:setVisible(false)
	
	self.children.menuSettings.signals.close = function()
		self:setState(self.kStates.menu)
	end
	
	self.children.title:animate(self.children.title.kAnimations.onFirstOpen)

	self:loadFilePlayer(kAssetsTracks.menu)
	
	timer.performAfterDelay(10, function()
		self:playSample(kAssetsSounds.intro)
		
		timer.performAfterDelay(300, function()
			self:playFilePlayer()
		end)
	end)
end

function WidgetMenu:_draw(frame, rect)
	self.painters.background:draw(frame)
	self.children.title:draw(rect)
	self.children.levelSelect:draw(frame:toLegacyRect(), rect)
	self.children.menuSettings:draw(frame:toLegacyRect(), rect)
end

function WidgetMenu:_update()
	self.index += 2
	
	if self.index % 40 > 32 then
		self.tick = self.tick == 0 and 1 or 0
	end
	
	if self.state == self.kStates.subMenu then
		self:passInput(self.children.menuSettings)
	elseif self.state == self.kStates.default then
		self:filterInput(playdate.kButtonA)
	elseif self.state == self.kStates.menu then
		self:passInput(self.children.levelSelect)
	end
end

function WidgetMenu:_handleInput(input)
	if input.pressed & playdate.kButtonA ~= 0 then
		self.tick = 0
		self:setState(self.kStates.menu)
	end
	
	if input.pressed & playdate.kButtonB ~= 0 then
		self.tick = 0
		self:setState(self.kStates.default)
	end
end

function WidgetMenu:_changeState(stateFrom, stateTo)
	if stateFrom == self.kStates.default and (stateTo == self.kStates.menu) then
		self:playSample(kAssetsSounds.menuAccept)
		
		if self.children.levelSelect == nil then
			self.children.levelSelect = Widget.new(LevelSelect)
			self.children.levelSelect:load()
		end
		
		self.children.title:animate(self.children.title.kAnimations.toLevelSelect, function(animationChanged)
			if not animationChanged then
				self.children.title:setVisible(false)
				self.children.levelSelect:setVisible(true)
				
				self.children.levelSelect:animate(self.children.levelSelect.kAnimations.intro)
			end
		end)
	end
	
	if stateFrom == self.kStates.menu and (stateTo == self.kStates.default) then
		self:playSample(kAssetsSounds.menuAccept)
		
		self.children.title:setVisible(true)
		self.children.levelSelect:setVisible(false)
		
		self.children.title:animate(self.children.title.kAnimations.fromLevelSelect)
	end
	
	if stateFrom == self.kStates.menu and (stateTo == self.kStates.subMenu) then
		self:playSample(kAssetsSounds.menuAccept)
		
		self.children.levelSelect:animate(self.children.levelSelect.kAnimations.outro, function()
			self.children.levelSelect:setVisible(false)
			self.children.menuSettings:setVisible(true)
			
			gfx.sprite.addDirtyRect(0, 0, 400, 240)
		end)
	end
	
	if stateFrom == self.kStates.subMenu and (stateTo == self.kStates.menu) then
		self:playSample(kAssetsSounds.menuAccept)
		self.children.menuSettings:setVisible(false)
		self.children.levelSelect:setVisible(true)
		
		self.children.levelSelect:animate(self.children.levelSelect.kAnimations.intro)
	end
end

function WidgetMenu:_unload()
	self.samples = nil
	self.painters = nil
	self.fileplayer = nil
	
	for _, child in pairs(self.children) do child:unload() end
	self.children = nil
end
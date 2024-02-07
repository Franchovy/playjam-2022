import "constant"
import "engine"
import "menu"
import "play"
import "loader/levelLoader"
import "loader/settings"

local timer <const> = playdate.timer
local disp <const> = playdate.display

class("WidgetMain").extends(Widget)

local function _loadLevelFromFile(filepath)
	return json.decodeFile(filepath)
end

function WidgetMain:init()
	WidgetMain.super.init(self)
	
	self:supply(Widget.deps.state)
	self:supply(Widget.deps.input)
	self:supply(Widget.deps.frame)
	
	self:setStateInitial({ menu = 1, play = 2 }, 1)
	
	self:setFrame(disp.getRect())
	self:createSprite(kZIndex.main)
	
	self.data = {}
	
	self.data.highscores = {}
end

function WidgetMain:_load()
	self.children.loaderSettings = Widget.new(WidgetLoaderSettings)
	self.children.loaderSettings:load()
	
	self.onReturnToMenu = function()
		self:setState(self.kStates.menu)
	end
	
	self.onMenuPressedPlay = function(config)
		self.data.currentLevel = {
			worldTitle = config.worldTitle,
			levelTitle = config.levelTitle,
			filepath = config.filepath
		}
		
		self:setState(self.kStates.play)
	end
	
	self.getNextLevelConfig = function()
		local level, world = self.children.loaderLevel:getNextLevel(self.data.currentLevel)
		
		if world ~= nil then
			self.data.currentLevel.worldTitle = world.title
		end
		
		self.data.currentLevel.levelTitle = level.title
		self.data.currentLevel.filePath = level.path
		
		local levelConfig = _loadLevelFromFile(level.path)
		
		return { level = levelConfig, levelInfo = self.data.currentLevel }
	end
	
	self.children.loaderLevel = Widget.new(WidgetLoaderLevel)
	self.children.loaderLevel:load()
	self.children.loaderLevel:refresh()
	
	local levels = self.children.loaderLevel:getLevels()
	
	self.children.menu = Widget.new(WidgetMenu, { levels = levels })
	self.children.menu:load()
	
	self.children.menu.signals.loadLevel = self.onMenuPressedPlay
	
	self.children.transition = Widget.new(WidgetTransition, { showLoading = true })
	self.children.transition:load()
	self.children.transition:setVisible(false)
end

function WidgetMain:_draw(frame, rect)
	if self.children.menu ~= nil then
		self.children.menu:draw(rect)
	end
		
	if self.children.play ~= nil then
		self.children.play:draw(frame:toLegacyRect(), rect)
	end
end

function WidgetMain:_update()
	self:registerDeviceInput()
	
	if self.state == self.kStates.menu and (self.children.menu ~= nil) then
		self:passInput(self.children.menu)
	elseif self.state == self.kStates.play and (self.children.play ~= nil) then
		self:passInput(self.children.play)
	end
end

function WidgetMain:_changeState(stateFrom, stateTo)
	if stateFrom == self.kStates.menu and (stateTo == self.kStates.play) then
		assert(self.data.currentLevel ~= nil, "Error: Cannot play without setting a level!")
		
		self.children.transition:setVisible(true)
		self.children.transition:setState(self.children.transition.kStates.closed)
		
		self.children.transition.signals.animationFinished = function()
			self.children.menu:setVisible(false)
			local levelConfig = _loadLevelFromFile(self.data.currentLevel.filepath)
			assert(levelConfig ~= nil, "Error: Missing level data!")
			
			if self.children.play == nil then
				self.children.menu:unload()
				self.children.menu = nil
				
				collectgarbage("collect")
				
				self.children.play = Widget.new(WidgetPlay, { level = levelConfig, levelInfo = self.data.currentLevel })
				self.children.play:load()
				
				self.children.play.signals.saveLevelScore = self.children.loaderLevel.onPlaythroughComplete
				self.children.play.signals.returnToMenu = self.onReturnToMenu
				self.children.play.signals.getNextLevelConfig = self.getNextLevelConfig
				
				timer.performAfterDelay(100, function()
					self.children.transition:setState(self.children.transition.kStates.open)
					self.children.transition.signals.animationFinished = function()
						self.children.transition:setVisible(false)
					end
				end)
			end
		end
	elseif stateFrom == self.kStates.play and (stateTo == self.kStates.menu) then
		self.children.transition:setVisible(true)
		self.children.transition:setState(self.children.transition.kStates.closed)
		
		self.children.transition.signals.animationFinished = function()
			self.children.play:setVisible(false)
			
			self.children.play:unload()
			self.children.play = nil 
			
			collectgarbage("collect")
			
			self.children.loaderLevel:refresh()
			
			local levels = self.children.loaderLevel:getLevels()
			
			self.children.menu = Widget.new(WidgetMenu, { levels = levels })
			self.children.menu:load()
			
			self.children.menu.signals.play = self.onMenuPressedPlay
			
			timer.performAfterDelay(100, function()
				self.children.transition:setState(self.children.transition.kStates.open)
				self.children.transition.signals.animationFinished = function()
					self.children.transition:setVisible(false)
				end
			end)
		end
	end
end
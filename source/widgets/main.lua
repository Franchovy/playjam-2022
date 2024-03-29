import "constant"
import "engine"
import "menu"
import "play"
import "loader/level"
import "loader/user"
import "loader/settings"

local timer <const> = playdate.timer
local disp <const> = playdate.display

class("WidgetMain").extends(Widget)

local function _loadLevelFromFile(filepath)
	return json.decodeFile(filepath)
end

function WidgetMain:_init()
	self:supply(Widget.deps.state)
	self:supply(Widget.deps.input)
	self:supply(Widget.deps.frame)
	
	self:setStateInitial(1, { "menu", "play" })
	
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
			filepath = config.filepath,
			hasNextLevel = config.hasNextLevel
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
	
	self.onPlaythroughComplete = function(playthroughData)
		self.children.loaderUser.onPlaythroughComplete(playthroughData)
		self.children.loaderLevel.onPlaythroughComplete(playthroughData)
	end
	
	self.reloadLevels = function()
		self.children.loaderLevel:refresh()
		
		self.children.menu:unload()
		self.children.menu.config.levels = self.children.loaderLevel:getLevels()
		self.children.menu:load()
	end
	
	self.children.loaderUser = Widget.new(WidgetLoaderUser)
	self.children.loaderUser:load()
	
	local coins = self.children.loaderUser:getCoinCount()
	
	self.children.loaderLevel = Widget.new(WidgetLoaderLevel)
	self.children.loaderLevel:load()
	self.children.loaderLevel:refresh()
	
	local levels = self.children.loaderLevel:getLevels()
	
	self.children.menu = Widget.new(WidgetMenu, { levels = levels, coins = coins })
	self.children.menu:load()
	
	self.children.menu.signals.loadLevel = self.onMenuPressedPlay
	self.children.menu.signals.reloadLevels = self.reloadLevels
	
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
		
		self.children.transition.cover(function()
			self.children.menu:setVisible(false)
			local levelConfig = _loadLevelFromFile(self.data.currentLevel.filepath)
			assert(levelConfig ~= nil, "Error: Missing level data!")
			
			if self.children.play == nil then
				self.children.menu:unload()
				self.children.menu = nil
				
				collectgarbage("collect")
				
				self.children.play = Widget.new(WidgetPlay, { level = levelConfig, levelInfo = self.data.currentLevel })
				self.children.play:load()
				
				self.children.play.signals.enableInGameOptimizations = function() self:setVisible(false); --[[playdate.setCollectsGarbage(false)--]] end
				self.children.play.signals.disableInGameOptimizations = function() self:setVisible(true); --[[playdate.setCollectsGarbage(true)--]] end

				self.children.play.signals.saveLevelScore = self.onPlaythroughComplete
				self.children.play.signals.returnToMenu = self.onReturnToMenu
				self.children.play.signals.getNextLevelConfig = self.getNextLevelConfig
				
				self.children.transition.uncover()
			end
		end)
	elseif stateFrom == self.kStates.play and (stateTo == self.kStates.menu) then
		self.children.transition.cover(function()
			self.children.play:setVisible(false)
			
			self.children.play:unload()
			self.children.play = nil 
			
			collectgarbage("collect")
			
			self.children.loaderLevel:refresh()
			
			local coins = self.children.loaderUser:getCoinCount()
			local levels = self.children.loaderLevel:getLevels()
			
			self.children.menu = Widget.new(WidgetMenu, { levels = levels, coins = coins })
			self.children.menu:load()
			
			self.children.menu.signals.loadLevel = self.onMenuPressedPlay
			
			self.children.transition.uncover()
		end)
	end
end
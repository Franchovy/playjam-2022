import "common/loading"
import "constant"
import "engine"
import "menu"
import "play"
import "utils/level"

class("WidgetMain").extends(Widget)

function WidgetMain:init()	
	self:supply(Widget.kDeps.children)
	self:supply(Widget.kDeps.state)
	
	self.kStates = { menu = 1, play = 2 }
	self.state = self.kStates.menu
	
	self:createSprite()
	self.sprite:setZIndex(1)
	self.sprite:add()
end

function WidgetMain:_load()
	self.children.menu = Widget.new(WidgetMenu, { levels = kLevels })
	self.children.menu:load()
	
	self.onPlaythroughComplete = function(data)
		-- TODO: if stats enabled, write (append) playthrough data into an existing or new file
		
		-- Write data into high-scores file
	end
	
	self.onReturnToMenu = function()
		self:setState(self.kStates.menu)
	end
	
	self.onMenuPressedPlay = function(filePathLevel)
		self.filePathLevel = filePathLevel
		self:setState(self.kStates.play)
	end
	
	self.getNextLevelConfig = function()
		local filePathNextLevel
		
		for _, v in pairs(kLevels) do
			if v.levelFileName == self.filePathLevel then
				self.filePathLevel = nil
			elseif self.filePathLevel == nil then
				self.filePathLevel = v.levelFileName
			end
		end
		
		if self.filePathLevel ~= nil then
			return loadLevelFromFile(self.filePathLevel)
		end
	end
	
	self.children.menu.signals.play = self.onMenuPressedPlay
	
	self.children.loading = Widget.new(WidgetLoading)
	self.children.loading:load()
	self.children.loading:setVisible(false)
end

function WidgetMain:_draw(rect)
	if self.state == self.kStates.menu and (self.children.menu ~= nil) then
		self.children.menu:draw(rect)
	end
	
	if self.state == self.kStates.play and (self.children.play ~= nil) then
		self.children.play:draw(rect)
	end
	
	self.children.loading:draw(rect)
end

function WidgetMain:_update()
	
end

function WidgetMain:_input()
	
end

function WidgetMain:changeState(stateFrom, stateTo)
	if stateFrom == self.kStates.menu and (stateTo == self.kStates.play) then
		self.children.menu:setVisible(false)
		self.children.loading:setVisible(true)
		
		playdate.timer.performAfterDelay(10, function()
			local levelConfig = loadLevelFromFile(self.filePathLevel)
			
			if self.children.play == nil then
				self.children.menu:unload()
				self.children.menu = nil
				
				collectgarbage("collect")
				
				self.children.play = Widget.new(WidgetPlay, levelConfig)
				self.children.play:load()
				
				self.children.play.signals.writeLevelPlaythrough = self.onPlaythroughComplete
				self.children.play.signals.returnToMenu = self.onReturnToMenu
				self.children.play.signals.getNextLevelConfig = self.getNextLevelConfig
				
				self.children.loading:setVisible(false)
			end
		end)
	elseif stateFrom == self.kStates.play and (stateTo == self.kStates.menu) then
		self.children.loading:setVisible(true)
		self.children.play:setVisible(false)
		
		playdate.timer.performAfterDelay(10, function()
			self.children.play:unload()
			self.children.play = nil 
			
			collectgarbage("collect")
			
			self.children.menu = Widget.new(WidgetMenu)
			self.children.menu:load()
			
			self.children.menu.signals.play = self.onMenuPressedPlay
			
			self.children.loading:setVisible(false)
		end)
	end
end
import "play/state"
import "play/level"
import "play/levelComplete"
import "play/gameOver"
import "play/background"
import "common/transition"

class("WidgetPlay").extends(Widget)

function WidgetPlay:init(config)
	self.config = config
	
	self:supply(Widget.kDeps.children)
	self:supply(Widget.kDeps.state)
	
	self:setStateInitial(kPlayStates, 1)
	
	self.children = {}
end

function WidgetPlay:_load()
	self.children.transition = Widget.new(WidgetTransition)
	self.children.transition:load()
	self.children.transition:setVisible(false)
	
	self.children.level = Widget.new(WidgetLevel, { objects = self.config.objects, objectives = self.config.objectives })
	self.children.level:load()
	
	self.children.level.signals.startPlaying = function()
		self:setState(self.kStates.playing)
	end
	
	self.children.level.signals.gameOver = function()
		self:setState(self.kStates.gameOver)
	end
	
	self.children.level.signals.levelComplete = function()
		self:setState(self.kStates.levelComplete)
	end
	
	self.children.gameOver = Widget.new(WidgetGameOver, { 
		reason = "YOU WERE KILLED"
	})
	self.children.gameOver:load()
	self.children.gameOver:setVisible(false)
	
	self.children.gameOver.signals.restartCheckpoint = function(entry) 
		self:setState(self.kStates.playing)
 	end
	self.children.gameOver.signals.restartLevel = function(entry) print("Selected restart level") end
	self.children.gameOver.signals.returnToMenu = function(entry) print("Selected return to menu") end
	
	-- Load theme for level
	
	if self.config.theme ~= nil then
		self.theme = kThemes[self.config.theme]
	end
	
	if AppConfig.enableBackgroundMusic and self.theme ~= nil then
		local musicFilePath = getMusicFilepathForTheme(self.theme)
		self.filePlayer = FilePlayer(musicFilePath)
		
		self.filePlayer:play()
	end
	
	if AppConfig.enableParalaxBackground and (self.config.theme ~= nil) then
		self.children.background = Widget.new(WidgetBackground, { theme = self.config.theme })
		self.children.background:load()
	end
end

function WidgetPlay:_draw(rect)
	if self.children.level ~= nil then
		self.children.level:draw(rect)
	end
	
	if self.children.levelComplete ~= nil then
		local insetRect = Rect.inset(rect, 30, 20)
		self.children.levelComplete:draw(insetRect)
	end

	self.children.gameOver:draw(rect)
end

function WidgetPlay:_update()
end

function WidgetPlay:changeState(stateFrom, stateTo)
	if stateFrom == self.kStates.start and (stateTo == self.kStates.playing) then
		self.children.level:setState(self.kStates.playing)
	elseif stateFrom == self.kStates.gameOver and (stateTo == self.kStates.playing) then
		self.children.transition:setVisible(true)
		self.children.transition:setState(self.children.transition.kStates.inside)
		
		playdate.timer.performAfterDelay(400, function()
			self.children.gameOver:setVisible(false)
			self.children.transition:setState(self.children.transition.kStates.outside)
			self.children.level:setState(self.kStates.playing)
			
			playdate.timer.performAfterDelay(400, function()
				self.children.transition:setVisible(false)
			end)
		end)
	elseif stateFrom == self.kStates.playing and (stateTo == self.kStates.gameOver) then
		self.filePlayer:stop()
		
		playdate.timer.performAfterDelay(1200, function()
			self.children.transition:setVisible(true)
			self.children.transition:setState(self.children.transition.kStates.inside)
			
			playdate.timer.performAfterDelay(500, function()
				self.children.level:setState(self.kStates.gameOver)
				
				self.children.transition:setState(self.children.transition.kStates.outside)
				
				self.children.gameOver:setVisible(true)
			end)
		end)
	elseif stateFrom == self.kStates.playing and (stateTo == self.kStates.levelComplete) then
		--playdate.timer.performAfterDelay(1500, function()
			self.children.level:setState(self.kStates.levelComplete)
			local objectives = table.shallowcopy(self.children.level.objectives)
			
			self.children.levelComplete = Widget.new(LevelComplete, {
				objectives = objectives,
				darkMode = self.config.theme ~= 1
			})
			self.children.levelComplete:load()
			
			playdate.timer.performAfterDelay(5000, function()
				self.children.levelComplete:setState(self.children.levelComplete.kStates.overlay)
			end)
		--end)
	end
end
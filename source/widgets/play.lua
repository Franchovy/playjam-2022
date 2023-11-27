import "play/state"
import "play/loading"
import "play/level"
import "play/levelComplete"
import "play/gameOver"
import "play/background"
import "common/transition"

class("WidgetPlay").extends(Widget)

function WidgetPlay:init(config)
	self.filePathLevel = config.filePathLevel
	
	self:supply(Widget.kDeps.children)
	self:supply(Widget.kDeps.state)
	
	self:setStateInitial(kPlayStates, 1)
	
	self.children = {}
end

function WidgetPlay:_load()
	self.children.loading = Widget.new(WidgetLoading)
	self.children.loading:load()
	
	self.config = json.decodeFile(self.filePathLevel)
	
	self.children.transition = Widget.new(WidgetTransition)
	self.children.transition:load()
	self.children.transition:setVisible(false)
	
	self.children.level = Widget.new(WidgetLevel, { levelConfig = self.config, levelCompleteCallback = levelCompleteCallback })
	self.children.level:load()
	
	self.children.loading:setVisible(false)
	
	self.children.level.signals.startPlaying = function()
		self:setState(kPlayStates.playing)
	end
	
	self.children.level.signals.playerDied = function()
		self.filePlayer:stop()
		
		playdate.timer.performAfterDelay(1200, function()
			self:setState(kPlayStates.stopped)
		end)
	end
	
	self.children.level.signals.levelComplete = function()
		playdate.timer.performAfterDelay(2500, function()
			self:setState(kPlayStates.stopped)
		end)
	end
	
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
	self.children.loading:draw(rect)
	
	if self.children.level ~= nil then
		self.children.level:draw(rect)
	end
	
	if self.children.levelComplete ~= nil then
		local insetRect = Rect.inset(rect, 30, 20)
		self.children.levelComplete:draw(insetRect)
	end

	if self.children.gameOver ~= nil then
		self.children.gameOver:draw(rect)
	end
end

function WidgetPlay:_update()
	-- Inherit state from level child
	
	--
	
	if self.children.background ~= nil then
		self.children.background:update()
	end
	
	if self.state == kPlayStates.stopped then
		if playdate.buttonIsPressed(playdate.kButtonA) then
			self.children.level:setState(kPlayStates.start)
		end
	end
end

function WidgetPlay:changeState(stateFrom, stateTo)
	if stateFrom == kPlayStates.start and (stateTo == kPlayStates.playing) then
		self.children.level:setState(kPlayStates.playing)
	elseif stateFrom == kPlayStates.stopped and (stateTo == kPlayStates.playing) then
		self.children.transition:setVisible(false)
		self.children.transition:setState(self.children.transition.kStates.outside)
	elseif stateFrom == kPlayStates.playing and (stateTo == kPlayStates.stopped) then
		if self.children.level.objectives ~= nil then
			-- Level Complete
			local config = table.shallowcopy(self.objectives)
			config.levelDarkMode = self.config.theme ~= 1
			
			self.children.levelComplete = Widget.new(LevelComplete, config)
			self.children.levelComplete:load()
			
			playdate.timer.performAfterDelay(5000, function()
				self.children.levelComplete:setState(self.children.levelComplete.kStates.overlay)
			end)
		else 
			-- Player died
			
			self.children.transition:setVisible(true)
			self.children.transition:setState(self.children.transition.kStates.inside)
			
			playdate.timer.performAfterDelay(500, function()
				self.children.level:setState(kPlayStates.stopped)
				
				self.children.transition:setState(self.children.transition.kStates.outside)
				
				if self.children.gameOver == nil then
					self.children.gameOver = Widget.new(WidgetGameOver, {reason = "YOU WERE KILLED"})
					self.children.gameOver:load()
				end
			end)
		end
	end
end
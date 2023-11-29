import "play/level"
import "play/levelComplete"
import "play/gameOver"
import "play/background"
import "play/hud"
import "common/transition"

class("WidgetPlay").extends(Widget)

function WidgetPlay:init(config)
	self.config = config
	
	self:supply(Widget.kDeps.children)
	self:supply(Widget.kDeps.state)
	
	self:setStateInitial({
		start = 1,
		playing = 2,
		gameOver = 3,
		levelComplete = 4
	}, 1)
	
	self.timers = {}
	self.data = {}
	
	--
	
	self.data.coins = 0
end

function WidgetPlay:_load()
	self.children.transition = Widget.new(WidgetTransition)
	self.children.transition:load()
	self.children.transition:setVisible(false)
	self.children.level = Widget.new(WidgetLevel, { objects = self.config.objects, objectives = self.config.objectives })

	self.children.level.signals.startPlaying = function()
		self:setState(self.kStates.playing)
	end
	
	self.children.level.signals.gameOver = function()
		self:setState(self.kStates.gameOver)
	end
	
	self.children.level.signals.levelComplete = function()
		self:setState(self.kStates.levelComplete)
	end
	
	self.children.level:load()
	
	self.children.hud = Widget.new(WidgetHUD)
	self.children.hud:load()
	
	self.children.level.signals.collectCoin = function(coinCount)
		self.data.coins += coinCount
	end
	
	self.children.gameOver = Widget.new(WidgetGameOver, { 
		reason = "YOU WERE KILLED"
	})
	self.children.gameOver:load()
	self.children.gameOver:setVisible(false)
	
	self.children.gameOver.signals.restartCheckpoint = function() 
		self:setState(self.kStates.playing)
 	end
	
	function self.restartLevel() 
		self.children.level:setState(self.children.level.kStates.unload)
 	end
	
	function self.returnToMenu() 
		self.children.level:setState(self.children.level.kStates.unload)
	end
	 
	self.children.gameOver.signals.restartLevel = self.restartLevel
	self.children.gameOver.signals.returnToMenu = self.returnToMenu
	
	-- Level Theme
	
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
	
	-- Level Timer
	
	self.timers.levelTimer = playdate.timer.new(999000)
	self.timers.levelTimer:pause()
	
	self.timers.levelTimer.updateCallback = function(timer)
		self.data.time = timer.currentTime
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
	
	local topAlignedRect = Rect.with(Rect.inset(rect, 7), { h = 29 })
	self.children.hud:draw(topAlignedRect)
end

function WidgetPlay:_update()
	if self.children.hud:isVisible() and (self.data.time ~= nil) and (self.data.coins ~= nil) then
		self.children.hud.data.time = self.data.time
		self.children.hud.data.coins = self.data.coins
	end
end

function WidgetPlay:changeState(stateFrom, stateTo)
	if stateFrom == self.kStates.start and (stateTo == self.kStates.playing) then
		self.children.level:setState(self.children.level.kStates.playing)
		self.timers.levelTimer:start()
		self.children.hud:setState(self.children.hud.kStates.onScreen)
	elseif stateFrom == self.kStates.gameOver and (stateTo == self.kStates.playing) then
		self.children.transition:setVisible(true)
		self.children.transition:setState(self.children.transition.kStates.inside)
		
		self.filePlayer:play()
		
		playdate.timer.performAfterDelay(400, function()
			self.children.gameOver:setVisible(false)
			self.children.transition:setState(self.children.transition.kStates.outside)
			self.children.level:setState(self.children.level.kStates.ready)
			
			playdate.timer.performAfterDelay(400, function()
				self.timers.levelTimer:start()
				self.children.transition:setVisible(false)
				
				self.children.hud:setState(self.children.hud.kStates.onScreen)
			end)
		end)
	elseif stateFrom == self.kStates.playing and (stateTo == self.kStates.gameOver) then
		self.filePlayer:stop()
		self.timers.levelTimer:pause()
		
		playdate.timer.performAfterDelay(1200, function()
			self.children.transition:setVisible(true)
			self.children.transition:setState(self.children.transition.kStates.inside)
			
			playdate.timer.performAfterDelay(500, function()
				self.children.level:setState(self.children.level.unloaded)
				
				self.children.transition:setState(self.children.transition.kStates.outside)
				
				self.children.gameOver:setVisible(true)
				
				self.children.hud:setState(self.children.hud.kStates.offScreen)
			end)
		end)
	elseif stateFrom == self.kStates.playing and (stateTo == self.kStates.levelComplete) then
		self.timers.levelTimer:pause()
		
		--self.children.level:setState(self.children.level.freeze)
		
		-- Calculate objectives reached
		local stars = 1
		
		local coinCountObjective = self.config.objectives[1].coins
		local timeObjective = self.config.objectives[2].time
		
		for _, objective in pairs(self.config.objectives) do
			local objectiveReached = true
			
			if objective.coins ~= nil then
				objectiveReached = objectiveReached and (self.data.coins >= objective.coins)
			end
			
			if objective.time ~= nil then
				objectiveReached = objectiveReached and self.timers.levelTimer.currentTime <= (objective.time * 1000)
			end
			
			if objectiveReached == true then
				stars += 1
			end
		end
		
		local timeString = convertToTimeString(self.timers.levelTimer.currentTime, 1)
		local timeStringObjective = convertToTimeString(timeObjective * 1000, 1)
		
		local objectives = {
			stars = stars,
			timeString = timeString,
			coinCount = self.data.coins,
			timeStringObjective = timeStringObjective,
			coinCountObjective = coinCountObjective
		}
		
		self.children.levelComplete = Widget.new(LevelComplete, {
			objectives = objectives,
			darkMode = self.config.theme ~= 1
		})
		self.children.levelComplete:load()
		
		self.children.levelComplete.signals.nextLevel = function()
			print("Start next level")
			self.children.level:setState(self.children.level.kStates.unloaded)
		end
		
		self.children.levelComplete.signals.restartLevel = self.restartLevel
		self.children.levelComplete.signals.returnToMenu = self.returnToMenu
		
		playdate.timer.performAfterDelay(4500, function()
			self.children.hud:setState(self.children.hud.kStates.offScreen)
		end)
		
		playdate.timer.performAfterDelay(5000, function()
			self.children.levelComplete:setState(self.children.levelComplete.kStates.overlay)
		end)
	end
end
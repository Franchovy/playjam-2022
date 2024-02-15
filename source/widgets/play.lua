import "common/transition"
import "play/level"
import "play/levelComplete"
import "play/gameOver"
import "play/background"
import "play/hud"
import "play/system"
import "play/countdown"
import "common/textAnimator"
import "utils/themes"

local gfx <const> = playdate.graphics
local timer <const> = playdate.timer
local disp <const> = playdate.display
local geo <const> = playdate.geometry

local _assign <const> = geo.rect.assign
local _tInset <const> = geo.rect.tInset
local _tSet <const> = geo.rect.tSet
local _convertMsTimeToString <const> = convertMsTimeToString

class("WidgetPlay").extends(Widget)


function WidgetPlay:_init()
	self:supply(Widget.deps.state, { substates = true })
	self:supply(Widget.deps.input)
	self:supply(Widget.deps.frame)
	self:supply(Widget.deps.timers)
	
	self:setFrame(disp.getRect())
	
	self:setStateInitial(1, {
		"start",
		"playing",
		"gameOver",
		"levelComplete"
	})
	
	self.timers = {}
	self.data = {}
	self.signals = {}
end

function WidgetPlay:_load()

	self.children.transition = Widget.new(WidgetTransition, { showLoading = false })
	self.children.transition:load()
	self.children.transition:setVisible(false)
	
	self.children.level = Widget.new(WidgetLevel, { objects = self.config.level.objects, objectives = self.config.level.objectives })

	self.children.level.signals.startPlaying = function()
		self:setState(self.kStates.playing)
	end
	
	self.children.level.signals.gameOver = function()
		if self.state == self.kStates.playing then
			self:setState(self.kStates.gameOver)
		end
	end
	
	self.children.level.signals.levelComplete = function()
		self:setState(self.kStates.levelComplete)
	end
	
	self.children.level.signals.onCheckpoint = function(checkpointData)
		self.children.checkpoint:setVisible(true)
		self.children.checkpoint.setPositionCentered(checkpointData.x, checkpointData.y)
		self.children.checkpoint.beginAnimation()
		
		self.timers.checkpoint = timer.performAfterDelay(3000, function()
			self.children.checkpoint.endAnimation()
		end)
		
		table.insert(self.data.checkpoints, {
			time = self.data.time + self.timers.levelTimer.currentTime,
			coins = self.data.coins
		})
	end
	
	self.children.level:load()
	
	self.resetData = function()
		self.data.coins = 0
		self.data.time = 0
		self.data.checkpoints = {
			{
				time = 0,
				coins = 0
			}
		}
	end
	
	self:resetData()
	
	self.children.hud = Widget.new(WidgetHUD)
	self.children.hud:load()
	self.children.hud:setFrame(_tSet(_tInset(_assign(nil, self.frame), 7, 7), nil, nil, nil, 29))
	
	self.children.level.signals.collectCoin = function(coinCount)
		self.data.coins += coinCount
	end
	
	self.children.checkpoint = Widget.new(WidgetTextAnimator, { text = "CHECKPOINT!"} )
	self.children.checkpoint:load()
	self.children.checkpoint:setVisible(false)
	
	self.children.gameOver = Widget.new(WidgetGameOver, { 
		reason = "YOU WERE KILLED"
	})
	self.children.gameOver:load()
	self.children.gameOver:setVisible(false)
	
	self.children.gameOver.signals.restartCheckpoint = function() 
		self.substate = "checkpoint"
		
		self:setState(self.kStates.start)
 	end

	 self.children.systemMenu = Widget.new(WidgetSystem)
	 self.children.systemMenu:load()
	
	function self.loadNextLevel()
		self.resetData()
		local configNextLevel = self.signals.getNextLevelConfig()
		
		if configNextLevel == nil then
			self.returnToMenu()
			return
		end
		
		self.substate = "nextLevel"
		
		self.config.level = configNextLevel.level
		self.config.levelInfo = configNextLevel.levelInfo
		
		self.children.level.config.objects = self.config.level.objects
		self.children.level.config.objectives = self.config.level.objectives
		
		self:setState(self.kStates.start)
	end
	
	function self.restartLevel() 
		self.resetData()
		
		self.substate = "restartLevel"
		
		self:setState(self.kStates.start)
 	end
	
	function self.returnToMenu()
		if AppConfig.enableBackgroundMusic == true then
			self.filePlayer:stop()
		end
		
		self.signals.returnToMenu()
	end
	
	self.children.gameOver.signals.restartLevel = self.restartLevel
	self.children.gameOver.signals.returnToMenu = self.returnToMenu

	self.children.systemMenu.signals.restartLevel = self.restartLevel
	self.children.systemMenu.signals.returnToMenu = self.returnToMenu
	
	-- Level complete (layout only)
	
	self.rects.levelComplete = _tInset(_assign(self.rects.levelComplete, self.frame), 30, 20)
	
	-- Level Theme
	
	self.loadTheme = function()
		if self.config.level.theme ~= nil then
			self.theme = kThemes[self.config.level.theme]
		end
		
		if AppConfig.enableBackgroundMusic and self.theme ~= nil then
			local introFilePath, loopFilePath = getMusicFilepathsForTheme(self.theme)
			
			if self.filePlayer ~= nil then
				self.filePlayer:stop()
				self.filePlayer = nil
			end
			
			self.filePlayer = FilePlayer(loopFilePath, introFilePath)
			self.filePlayer:play()
		end
		
		if AppConfig.enableParalaxBackground and (self.config.level.theme ~= nil) then
			if self.children.background ~= nil then
				self.children.background:unload()
				
				self.children.background.theme = self.config.level.theme
			else
				self.children.background = Widget.new(WidgetBackground, { theme = self.config.level.theme })
			end
			
			self.children.background:load()
		end
		
		collectgarbage("collect")
		
		local backgroundColor = getBackgroundColorForTheme(self.theme)
		gfx.setBackgroundColor(backgroundColor)
	end
	
	self.loadTheme()
	
	-- Level Timer
	
	self.timers.levelTimer = timer.new(999000)
	self.timers.levelTimer:pause()
	
	self.children.countdown = Widget.new(WidgetCountdown, {})
	self.children.countdown:load()
	
	self.children.countdown.signals.finished = function() 
		self:setState(self.kStates.playing)
	end
-- DEBUG: Timer to trigger level complete
	--[[ 
	self:performAfterDelay(5000, function()
		self:setState(self.kStates.levelComplete)
	end)
	--]]
end

function WidgetPlay:_draw(frame, rect)
	local _rects = self.rects
	
	if self.children.levelComplete ~= nil then
		self.children.levelComplete:draw(_rects.levelComplete:toLegacyRect())
	end

	if self.state == self.kStates.gameOver then
		self.children.gameOver:draw(frame:toLegacyRect())
	end
end

function WidgetPlay:_update()
	if self.children.hud:isVisible() and (self.data.time ~= nil) and (self.data.coins ~= nil) then
		self.children.hud.data.time = self.data.time + self.timers.levelTimer.currentTime
		self.children.hud.data.coins = self.data.coins
	end
	
	if playdate.isCrankDocked() and (self.state == self.kStates.playing or (self.state == self.kStates.start)) then
		g.showCrankIndicator = true
	end
	
	if self.state == self.kStates.levelComplete then
		self:passInput(self.children.levelComplete)
	elseif self.state == self.kStates.gameOver then
		self:passInput(self.children.gameOver)
	end
end

function WidgetPlay:_changeState(stateFrom, stateTo)
	if stateTo == self.kStates.start then
		self.timers.levelTimer:pause()
		self.signals.enableInGameOptimizations()
		
		if AppConfig.enableBackgroundMusic == true then
			self.filePlayer:stop()
		end
		
		self.children.transition.cover(function()
			if self.children.levelComplete ~= nil then
				self.children.levelComplete:setVisible(false)
			end
			
			if self.children.gameOver ~= nil then
				self.children.gameOver:setVisible(false)
			end
			
			if self.children.level.isLevelLoaded == true then
				self.children.level:unloadLevel()
			end
			
			self.children.level:setState(self.children.level.kStates.frozen)
			self.children.hud:setState(self.children.hud.kStates.offScreen)
			
			if self.substate == "checkpoint" then
				self.children.level.loadCheckpoint()
			elseif self.substate == "nextLevel" then
				self.children.level.loadNextLevel()
			elseif self.substate == "restartLevel" then
				self.children.level.loadLevelRestart()
			end
			
			if self.theme ~= kThemes[self.config.level.theme] then
				self.loadTheme()
			end
			
			self.timers.levelTimer:reset()
			
			collectgarbage("collect")
					
			self.children.transition.uncover(function()
				if self.substate == "checkpoint" then
					self:setState(self.kStates.playing)
				else
					self.children.countdown.levelStartCountdown()
				end
				
				if AppConfig.enableBackgroundMusic == true then
					self.filePlayer:play()
				end
			end)
		end)
	elseif stateTo == self.kStates.playing then
		self.children.level:setState(self.children.level.kStates.playing)
		self.timers.levelTimer:start()
		self.children.hud:setState(self.children.hud.kStates.onScreen)
	elseif stateFrom == self.kStates.playing and stateTo == self.kStates.gameOver then
		self.signals.disableInGameOptimizations()
		
		if AppConfig.enableBackgroundMusic == true then
			self.filePlayer:stop()
		end
		
		self.timers.levelTimer:pause()
		
		self.children.level:setState(self.children.level.kStates.frozen)
		
		self:performAfterDelay(1200, function()
			self.children.transition.cover(function()
				local checkpointData = table.last(self.data.checkpoints)
				self.data.coins = checkpointData.coins
				self.data.time = checkpointData.time + self.timers.levelTimer.currentTime
				
				self.timers.levelTimer:reset()
				
				self.children.level:unloadLevel()
				self.children.gameOver:setVisible(true)
				self.children.hud:setState(self.children.hud.kStates.offScreen)
				
				collectgarbage("collect")
				
				self.children.transition.uncover()
			end)
		end)
	elseif stateFrom == self.kStates.playing and (stateTo == self.kStates.levelComplete) then
		self.signals.disableInGameOptimizations()
		
		self.timers.levelTimer:pause()
		
		-- Calculate objectives reached
		local stars = 0
		local objectives = self.config.level.objectives
		local timeValue = (self.data.time + self.timers.levelTimer.currentTime) / 10
		
		for _, objective in pairs(objectives) do
			if objective > timeValue then
				stars += 1
			end
		end
		
		self.signals.saveLevelScore {
			stars = tostring(stars),
			time = string.format("%d", math.ceil(timeValue)),
			levelTitle = self.config.levelInfo.levelTitle,
			worldTitle = self.config.levelInfo.worldTitle,
			coins = self.data.coins
		}
		
		self.children.levelComplete = Widget.new(LevelComplete, {
			objectives = {
				stars = stars,
				timeString = _convertMsTimeToString(timeValue * 10, 1).."/".._convertMsTimeToString(objectives[3] * 10, 1),
				coinsString = tostring(self.data.coins)
			},
			titleColor = getForegroundColorForTheme(self.theme)
		})
		self.children.levelComplete:load()
		
		self.children.levelComplete.signals.nextLevel = self.loadNextLevel
		self.children.levelComplete.signals.restartLevel = self.restartLevel
		self.children.levelComplete.signals.returnToMenu = self.returnToMenu
		
		self:performAfterDelay(2500, function()
			self.children.hud:setState(self.children.hud.kStates.offScreen)
			
			self:performAfterDelay(500, function()
				self.children.level:setState(self.children.level.kStates.frozen)
				
				self.children.levelComplete:setState(self.children.levelComplete.kStates.overlay)
			end)
		end)
	end
end

function WidgetPlay:_unload()	
	self.painters = nil
	self.fileplayer = nil
	
	for _, child in pairs(self.children) do child:unload() end
	self.children = nil
end
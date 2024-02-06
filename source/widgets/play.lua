import "common/transition"
import "play/level"
import "play/levelComplete"
import "play/gameOver"
import "play/background"
import "play/hud"
import "play/system"
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

function WidgetPlay:init(config)
	WidgetPlay.super.init(self)
	
	self.config = config
	
	self:supply(Widget.deps.state)
	self:supply(Widget.deps.input)
	self:supply(Widget.deps.frame)
	
	self:setFrame(disp.getRect())
	
	self:setStateInitial({
		start = 1,
		playing = 2,
		gameOver = 3,
		checkpoint = 4,
		levelComplete = 5
	}, 1)
	
	self.timers = {}
	self.data = {}
	self.signals = {}
end

function WidgetPlay:_load()
	self.children.transition = Widget.new(WidgetTransition)
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
	
	self.children.level.signals.onCheckpoint = function()
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
	
	self.children.gameOver = Widget.new(WidgetGameOver, { 
		reason = "YOU WERE KILLED"
	})
	self.children.gameOver:load()
	self.children.gameOver:setVisible(false)
	
	self.children.gameOver.signals.restartCheckpoint = function() 
		self:setState(self.kStates.checkpoint)
 	end

	 self.children.systemMenu = Widget.new(WidgetSystem)
	 self.children.systemMenu:load()
	
	function self.restartLevel() 
		self.resetData()
		
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
				self.children.background.sprite:remove()
				self.children.background = nil
			end
			
			self.children.background = Widget.new(WidgetBackground, { theme = self.config.level.theme })
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
	
	self.children.hud:setState(self.children.hud.kStates.onScreen)
	
	timer.performAfterDelay(5000, function()
		self:setState(self.kStates.levelComplete)
	end)
end

function WidgetPlay:_draw(frame, rect)
	local _rects = self.rects
	
	if self.children.levelComplete ~= nil then
		self.children.levelComplete:draw(_rects.levelComplete:toLegacyRect())
	end

	if self.state == self.kStates.gameOver then
		self.children.gameOver:draw(frame:toLegacyRect())
	end
	
	self.children.hud:draw(rect)
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
	if stateTo == self.kStates.playing then
		self.children.level:setState(self.children.level.kStates.playing)
		self.timers.levelTimer:start()
		self.children.hud:setState(self.children.hud.kStates.onScreen)
	elseif stateFrom == self.kStates.gameOver and (stateTo == self.kStates.checkpoint) then
		self.children.transition:setVisible(true)
		self.children.transition:setState(self.children.transition.kStates.closed)
		
		self.children.transition.signals.animationFinished = function()
			self.children.gameOver:setVisible(false)
			
			self.children.level:setState(self.children.level.kStates.restartCheckpoint)
			self.children.level:setState(self.children.level.kStates.ready)

			collectgarbage("collect")
			
			timer.performAfterDelay(10, function()
				if AppConfig.enableBackgroundMusic == true then
					self.filePlayer:play()
				end

				self.children.transition:setState(self.children.transition.kStates.open)
				
				self.children.transition.signals.animationFinished = function()
					self:setState(self.kStates.playing)
				end
			end)
		end
	elseif stateFrom == self.kStates.playing and (stateTo == self.kStates.gameOver) then
		if AppConfig.enableBackgroundMusic == true then
			self.filePlayer:stop()
		end
		
		self.timers.levelTimer:pause()
		
		timer.performAfterDelay(1200, function()
			self.children.transition:setVisible(true)
			self.children.transition:setState(self.children.transition.kStates.closed)
			
			self.children.transition.signals.animationFinished = function()
				local checkpointData = table.last(self.data.checkpoints)
				self.data.coins = checkpointData.coins
				self.data.time = checkpointData.time
				self.timers.levelTimer:reset()
				
				self.children.level:setState(self.children.level.kStates.unloaded)
				
				self.children.gameOver:setVisible(true)
				self.children.hud:setState(self.children.hud.kStates.offScreen)
				
				collectgarbage("collect")
				
				self.children.transition:setState(self.children.transition.kStates.open)
				self.children.transition.signals.animationFinished = function()
					self.children.transition:setVisible(false)
				end
			end
		end)
	elseif stateFrom == self.kStates.playing and (stateTo == self.kStates.levelComplete) then
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
			worldTitle = self.config.levelInfo.worldTitle
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
		
		self.children.levelComplete.signals.nextLevel = function()
			local configNextLevel = self.signals.getNextLevelConfig()
			
			if configNextLevel == nil then
				self.returnToMenu()
				return
			end
			
			self.config.level = configNextLevel.level
			self.config.levelInfo = configNextLevel.levelInfo
			
			self.children.level.config.objects = self.config.level.objects
			self.children.level.config.objectives = self.config.level.objectives
			
			self:setState(self.kStates.start)
		end
		
		self.children.levelComplete.signals.restartLevel = self.restartLevel
		self.children.levelComplete.signals.returnToMenu = self.returnToMenu
		
		timer.performAfterDelay(2500, function()
			self.children.hud:setState(self.children.hud.kStates.offScreen)
		end)
		
		timer.performAfterDelay(3000, function()
			self.children.level:setState(self.children.level.kStates.frozen)
			
			self.children.levelComplete:setState(self.children.levelComplete.kStates.overlay)
		end)
	elseif stateTo == self.kStates.start then
		self.children.transition:setVisible(true)
		self.children.transition:setState(self.children.transition.kStates.closed)
		
		self.timers.levelTimer:pause()
		
		self.children.level:setState(self.children.level.kStates.frozen)
		
		if AppConfig.enableBackgroundMusic == true then
			self.filePlayer:stop()
		end
		
		self.children.transition.signals.animationFinished = function()
			if self.children.levelComplete ~= nil and (self.children.levelComplete:isVisible() == true) then
				self.children.levelComplete:setVisible(false)
			end
			
			if self.children.gameOver ~= nil and (self.children.gameOver:isVisible() == true) then
				self.children.gameOver:setVisible(false)
			end
			
			self.resetData()
			
			self.children.level:setState(self.children.level.kStates.unloaded)
			
			if stateFrom == self.kStates.levelComplete then
				self.loadTheme()
				self.children.level:setState(self.children.level.kStates.nextLevel)
			else
				self.children.level:setState(self.children.level.kStates.restartLevel)
			end
			
			self.children.hud:setState(self.children.hud.kStates.offScreen)
			
			self.timers.levelTimer:reset()
			self.children.level:setState(self.children.level.kStates.ready)
			
			collectgarbage("collect")
			
			timer.performAfterDelay(10, function()
				self.children.transition:setState(self.children.transition.kStates.open)
				
				self.children.transition.signals.animationFinished = function()
					self.children.transition:setVisible(false)
					
					self.children.hud:setState(self.children.hud.kStates.onScreen)
					
					if AppConfig.enableBackgroundMusic == true then
						self.filePlayer:play()
					end
				end
			end)
		end
	end
end

function WidgetPlay:_unload()
	self.samples = nil
	self.painters = nil
	self.fileplayer = nil
	self.timers = nil
	
	for _, child in pairs(self.children) do child:unload() end
	self.children = nil
end
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
	
	self.kStates = { menu = 1, play = 2 }
	self.state = self.kStates.menu
	
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
	
	self.onMenuPressedPlay = function(level)
		self.level = level
		self:setState(self.kStates.play)
	end
	
	self.getNextLevelConfig = function()
		for _, v in pairs(kLevels) do
			if self.level == nil then
				self.level = v
				break
			elseif v.path == self.level.path then
				self.level = nil
			end
		end
		
		if self.level ~= nil then
			return _loadLevelFromFile(self.level.path)
		end
	end
	
	self.children.loaderLevel = Widget.new(WidgetLoaderLevel)
	self.children.loaderLevel:load()
	self.children.loaderLevel:refresh()
	
	local levels, scores, levelsLocked = self.children.loaderLevel:getLevels()
	
	--
	
	--[[ 
		levels (worlds): { 
			1 = { 
				title = "mountain", 
				levels = { 
					1 = { 
						title = "1",
						score = { 
							time = 90,
							stars = 3
						}, 
						objectives = { 
							1 = 110,
							2 = 90,
							3 = 60,
							4 = 50
						},
						locked = false
					},
					...
				},
				score = 12,
				locked = false
			},
			...
		}
	--]]
	
	self.children.menu = Widget.new(WidgetMenu, { levels = levels })
	self.children.menu:load()
	
	self.children.menu.signals.play = self.onMenuPressedPlay
	
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
		self.children.transition:setVisible(true)
		self.children.transition:setState(self.children.transition.kStates.closed)
		
		self.children.transition.signals.animationFinished = function()
			self.children.menu:setVisible(false)
			local levelConfig = _loadLevelFromFile(self.level.path)
			
			if self.children.play == nil then
				self.children.menu:unload()
				self.children.menu = nil
				
				collectgarbage("collect")
				
				self.children.play = Widget.new(WidgetPlay, levelConfig)
				self.children.play:load()
				
				self.children.play.signals.saveLevelScore = self.onPlaythroughComplete
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
			
			self.children.menu = Widget.new(WidgetMenu, { levels = kLevels, scores = self.data.highscores, locked = self.data.levelsLocked })
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
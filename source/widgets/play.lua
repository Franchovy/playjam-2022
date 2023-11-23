import "play/state"
import "play/loading"
import "play/level"
import "play/levelComplete"
import "play/gameOver"
import "play/background"

class("WidgetPlay").extends(Widget)

function WidgetPlay:init(config)
	self.filePathLevel = config.filePathLevel
	
	self:supply(Widget.kDeps.children)
	self:supply(Widget.kDeps.state)
	
	self:setStateInitial(kPlayStates, 1)
	
	self.children = {}
	
	self.objectives = nil
end

function WidgetPlay:_load()
	self.children.loading = Widget.new(WidgetLoading)
	self.children.loading:load()
	
	local levelCompleteCallback = function(objectives)
		self.objectives = objectives
		self:setState(kPlayStates.stopped)
	end
	
	self.config = json.decodeFile(self.filePathLevel)
	
	playdate.timer.performAfterDelay(100, function()
		self.children.level = Widget.new(WidgetLevel, { filePathLevel = self.filePathLevel, levelCompleteCallback = levelCompleteCallback })
		self.children.level:load()
		self:setState(kPlayStates.playing)
		
		self.children.loading:setVisible(false)
	end)
	
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
	
	if self.state == kPlayStates.stopped then
		if self.children.gameOver ~= nil then
			self.children.gameOver:draw(rect)
		end
	end
end

function WidgetPlay:_update()
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
		
	elseif stateFrom == kPlayStates.stopped and (stateTo == kPlayStates.playing) then
		if self.children.gameOver.isAdded == true then
			self.children.gameOver.sprite:remove()
		end
	elseif stateFrom == kPlayStates.playing and (stateTo == kPlayStates.stopped) then
		if self.objectives ~= nil then
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
			
			if self.children.gameOver == nil then
				self.children.gameOver = Widget.new(WidgetGameOver)
				self.children.gameOver:load()
			end
			
			self.children.gameOver.sprite:add()
			self.children.gameOver.isAdded = true
		end
	end
end
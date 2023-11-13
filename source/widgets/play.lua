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
end

function WidgetPlay:_load()
	self.children.loading = Widget.new(WidgetLoading)
	self.children.loading:load()
	
	self.config = json.decodeFile(self.filePathLevel)
	local theme = self.config.theme
	local levelDarkMode = self.config.theme ~= 1
	
	playdate.timer.performAfterDelay(100, function()
		self.children.level = Widget.new(WidgetLevel, { filePathLevel = self.filePathLevel })
		self.children.level:load()
		
		self.children.loading:setVisible(false)
	end)
	
	playdate.timer.performAfterDelay(3000, function()
		self.children.levelComplete = Widget.new(LevelComplete, { levelDarkMode = levelDarkMode, numStars = 1 })
		self.children.levelComplete:load()
		
		playdate.timer.performAfterDelay(5000, function()
			self.children.levelComplete:setState(self.children.levelComplete.kStates.overlay)
		end)
	end)
	
	if AppConfig.enableParalaxBackground and (theme ~= nil) then
		self.children.background = Widget.new(WidgetBackground, { theme = theme })
		self.children.background:load()
	end
	
end

function WidgetPlay:_draw(rect)
	self.children.loading:draw(rect)
	
	if self.children.level ~= nil then
		self.children.level:draw(rect)
	end
	
	if self.children.levelComplete ~= nil then
		local insetRect = Rect.inset(rect, 30, 30)
		self.children.levelComplete:draw(insetRect)
	end
end

function WidgetPlay:_update()
	if self.children.background ~= nil then
		self.children.background:update()
	end
end

function WidgetPlay:changeState(stateFrom, stateTo)
	if stateFrom == kPlayStates.start and (stateTo == kPlayStates.playing) then
		
	elseif stateFrom == kPlayStates.stopped and (stateTo == kPlayStates.playing) then
			
	elseif stateFrom == kPlayStates.playing and (stateTo == kPlayStates.stopped) then
		
	end
end
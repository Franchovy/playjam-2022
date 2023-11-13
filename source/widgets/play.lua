import "play/state"
import "play/loading"
import "play/level"
import "play/levelComplete"
import "play/gameOver"

class("WidgetPlay").extends(Widget)

function WidgetPlay:init(config)
	self.filePathLevel = config.filePathLevel
	
	self:supply(Widget.kDeps.children)
	self:supply(Widget.kDeps.state)
	
	self:setStateInitial(kPlayStates, 1)
end

function WidgetPlay:_load()
	self.children.loading = Widget.new(WidgetLoading)
	self.children.loading:load()
	
	-- Async load
	
	playdate.timer.performAfterDelay(100, function()
		self.children.level = Widget.new(WidgetLevel, { filePathLevel = self.filePathLevel })
		self.children.level:load()
		
		self.children.loading:setVisible(false)
	end)
	
	playdate.timer.performAfterDelay(3000, function()
		self.children.levelComplete = Widget.new(LevelComplete)
		self.children.levelComplete:load()
	end)
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
	
end 
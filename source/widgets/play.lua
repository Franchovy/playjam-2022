import "play/loading"
import "play/level"

class("WidgetPlay").extends(Widget)

function WidgetPlay:init(config)
	self.filePathLevel = config.filePathLevel
	
	self:supply(Widget.kDeps.children)
	self:supply(Widget.kDeps.state)
	
	self:setStateInitial({
		starting = 1,
		playing = 2,
		dead = 3,
		complete = 4
	}, 1)
end

function WidgetPlay:_load()
	self.children.loading = Widget.new(WidgetLoading)
	self.children.loading:load()
	
	-- Async load
	
	self.children.level = Widget.new(WidgetLevel, { filePathLevel = self.filePathLevel })
	self.children.level:load()
end

function WidgetPlay:_draw(rect)
	self.children.loading:draw(rect)
	
	self.children.level:draw()
end

function WidgetPlay:_update()
	self.children.loading:update()
	
	self.children.level:update()
end 
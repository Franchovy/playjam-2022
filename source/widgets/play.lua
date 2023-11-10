import "play/loading"

class("WidgetPlay").extends(Widget)

function WidgetPlay:init()
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
end

function WidgetPlay:_draw(rect)
	self.children.loading:draw(rect)
end

function WidgetPlay:_update()
	self.children.loading:update()
end 
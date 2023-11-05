import "engine"
import "menu"

class("WidgetMain").extends(Widget)

function WidgetMain:init()	
	self:supply(Widget.kDeps.children)
	self:supply(Widget.kDeps.state)
	
	self.kStates = { menu = 1, play = 2 }
	self.state = self.kStates.menu
	
	self:load()
end

function WidgetMain:load()
	self.children.menu = WidgetMenu()
	
	self.children.menu:load()
end

function WidgetMain:draw(rect)
	if self.state == self.kStates.menu then
		self.children.menu:draw(rect)
	end
end

function WidgetMain:update()
	if self.state == self.kStates.menu then
		self.children.menu:update()
	end
end

function WidgetMain:input()
	
end
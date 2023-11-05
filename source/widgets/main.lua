import "engine"
import "menu"

class("WidgetMain").extends(Widget)

function WidgetMain:init()	
	self:supply(Widget.kDeps.children)
	self:supply(Widget.kDeps.state)
	
	self.kStates = { menu = 1, play = 2 }
	self.state = self.kStates.menu
	
	self.initialLoad = false
end

function WidgetMain:load()
	self.children.menu = WidgetMenu()
	self.children.menu:load()
	
	self.initialLoad = true
end

function WidgetMain:draw(rect)
	if self.initialLoad == false then 
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.fillRect(0, 0, 400, 240)
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		
		local loadingText = playdate.graphics.imageWithText("LOADING...", 120, 20):scaledImage(2):invertedImage()
		local loadingTextRect = Rect.size(loadingText:getSize())
		local displayRect = Rect.size(playdate.display.getSize())
		local centerRect = Rect.center(loadingTextRect, displayRect)
		loadingText:draw(centerRect.x, centerRect.y)
	end
	
	if self.initialLoad and self.state == self.kStates.menu then
		self.children.menu:draw(rect)
	end
end

function WidgetMain:update()
	if self.initialLoad and self.state == self.kStates.menu then
		self.children.menu:update()
	end
end

function WidgetMain:input()
	
end
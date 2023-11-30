import "common/loading"
import "engine"
import "menu"
import "play"
import "utils/level"

class("WidgetMain").extends(Widget)

function WidgetMain:init()	
	self:supply(Widget.kDeps.children)
	self:supply(Widget.kDeps.state)
	
	self.kStates = { menu = 1, play = 2 }
	self.state = self.kStates.menu
	
	self:createSprite()
	self.sprite:setZIndex(1)
	self.sprite:add()
end

function WidgetMain:_load()
	self.playCallback = function(levelPath)
		self.children.menu:setVisible(false)
		self.children.loading:setVisible(true)
		
		playdate.timer.performAfterDelay(10, function()
			local levelConfig = loadLevelFromFile(levelPath)
			
			if self.children.play == nil then
				self.children.play = Widget.new(WidgetPlay, levelConfig)
				self.children.play:load()
				
				self.children.play.signals.writeLevelPlaythrough = function(data)
					
				end
				
				self.children.play.signals.returnToMenu = function()
					
				end
				
				self.children.loading:setVisible(false)
			end
		end)
	end
	
	self.children.menu = Widget.new(WidgetMenu, { playCallback = self.playCallback })
	self.children.menu:load()
	
	self.children.loading = Widget.new(WidgetLoading)
	self.children.loading:load()
	self.children.loading:setVisible(false)
end

function WidgetMain:_draw(rect)
	if self:isLoaded() == false then 
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.fillRect(0, 0, 400, 240)
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		
		local loadingText = playdate.graphics.imageWithText("LOADING...", 120, 20):scaledImage(2):invertedImage()
		local loadingTextRect = Rect.size(loadingText:getSize())
		local displayRect = Rect.size(playdate.display.getSize())
		local centerRect = Rect.center(loadingTextRect, displayRect)
		loadingText:draw(centerRect.x, centerRect.y)
	end
	
	if (self:isLoaded() == true) and (self.state == self.kStates.menu) then
		self.children.menu:draw(rect)
	end
	
	if self.children.play ~= nil then
		self.children.play:draw(rect)
	end
	
	self.children.loading:draw(rect)
end

function WidgetMain:_update()
	
end

function WidgetMain:_input()
	
end
import "engine.lua"
import "assets"
import "sprites/lib"
import "notify"
import "config"
import "widgets"

local topLevelWidget

-- Globals table -- Use sparingly!
g = {}

function initialize()
	playdate.graphics.setFont(playdate.graphics.font.new(kAssetsFonts.twinbee))
	playdate.graphics.setFontTracking(1)
	
	topLevelWidget = Widget.new(WidgetMain)
	
	playdate.timer.performAfterDelay(1, function()
		topLevelWidget:load()
	end)
	
	g.showCrankIndicator = false
end

function playdate.update()
	math.randomseed(playdate.getSecondsSinceEpoch())
	topLevelWidget:update()
	playdate.graphics.sprite.update()
	playdate.timer.updateTimers()
	playdate.frameTimer.updateTimers()
	playdate.graphics.animation.blinker.updateAll()
	
	if g.showCrankIndicator ~= false then
		if playdate.ui.crankIndicator.bubbleX == nil then
			playdate.ui.crankIndicator:start()
		end
		
		playdate.ui.crankIndicator:update()
		
		g.showCrankIndicator = false
	end
	
	playdate.drawFPS(10, 10)
end

-- Start game

initialize()

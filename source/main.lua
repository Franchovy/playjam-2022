import "engine.lua"
import "assets"
import "scenes/scenes"
import "sprites/lib"
import "notify"
import "config"
import "widgets"

local topLevelWidget

function initialize()
	playdate.graphics.setFont(playdate.graphics.font.new(kAssetsFonts.twinbee))
	playdate.graphics.setFontTracking(1)
	
	topLevelWidget = Widget.new(WidgetMain)
	
	playdate.timer.performAfterDelay(1, function()
		topLevelWidget:load()
	end)
end

function playdate.update()
	math.randomseed(playdate.getSecondsSinceEpoch())
	topLevelWidget:update()
	playdate.graphics.sprite.update()
	playdate.timer.updateTimers()
	playdate.frameTimer.updateTimers()
	playdate.graphics.animation.blinker.updateAll()
	playdate.drawFPS(10, 10)
end

-- Start game

initialize()

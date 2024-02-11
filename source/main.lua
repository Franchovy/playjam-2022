import "assets"
import "constant"
import "engine"
import "sprites/lib"
import "config"
import "widgets"
import "utils/fonts"
import "runTests"
import "engine/debugCanvas"

local topLevelWidget

-- Globals table -- Use sparingly!
g = {
	showCrankIndicator = false,
	runTests = true	-- run some tests before initializing the game
}

function initialize()
	setCurrentFontDefault(kAssetsFonts.twinbee)
	playdate.graphics.setFontTracking(1)
	
	topLevelWidget = Widget.new(WidgetMain)
	DebugCanvas()
	
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
	
	if g.showCrankIndicator ~= false then
		if playdate.ui.crankIndicator.bubbleX == nil then
			playdate.ui.crankIndicator:start()
		end
		
		playdate.ui.crankIndicator:update()
		
		g.showCrankIndicator = false
	end
	
	--[[
	playdate.drawFPS(10, 10)
	--]]
	--[[
	DebugCanvas.instance():draw()
	--]]
end

-- Start game

if g.runTests then
	runTests()
end

initialize()

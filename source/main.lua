import "engine.lua"
import "assets"
import "scenes/scenes"
import "sprites/lib"
import "notify"
import "config"
import "widgets"

local acceptsRestart = false
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
	sprite.update()
	timer.updateTimers()
	playdate.graphics.animation.blinker.updateAll()
	topLevelWidget:update()
	playdate.drawFPS(10, 10)
end

function placeholder()
	playdate.graphics.sprite.redrawBackground()

	-- Random Seed (for generating random numbers)
	math.randomseed(playdate.getSecondsSinceEpoch())

	-- Game Update

	Scene.update()
	timer.updateTimers()
	sprite.update()
	frameTimer.updateTimers()

	-- State management
	
	updateScenes()
end

function isGameSceneOver()
	return scenes.game.gameState == gameStates.playerDied
end

function transitionToGameOverScene()
	local gameScene = sceneManager.currentScene
	sceneManager:switchScene(scenes.gameover, function () gameScene:destroy() end)
end


function updateScenes()
	if sceneManager.currentScene == scenes.game then
		if isGameSceneOver() then
			transitionToGameOverScene()
		end
	end
end

-- Start game

initialize()

import "engine.lua"
import "assets"
import "scenes/scenes"
import "sprites/lib"
import "notify"
import "config"
import "widgets"

local acceptsRestart = false
local mainWidget = nil

function initialize()
	playdate.graphics.setFont(playdate.graphics.font.new(kAssetsFonts.twinbee))
	playdate.graphics.setFontTracking(1)
	
	Widget.main(WidgetMain)
	
	playdate.timer.performAfterDelay(1, function()
		Widget.topLevelWidget:load()
	end)
end

function playdate.update()
	Widget.update()
	
	sprite.update()
	playdate.graphics.sprite.redrawBackground()
	timer.updateTimers()
end

function placeholder()
	playdate.graphics.sprite.redrawBackground()

	-- Random Seed (for generating random numbers)
	math.randomseed(playdate.getSecondsSinceEpoch())

	-- Game Update

	Scene.update()
	playdate.graphics.animation.blinker.updateAll()
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

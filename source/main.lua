import "engine.lua"
import "assets"
import "scenes/scenes"
import "sprites/lib"
import "utils/level"
import "notify"
import "config"

local acceptsRestart = false


function initialize()
	gfx.setFont(gfx.font.new(kAssetsFonts.twinbee))
	createLevelPathIfNeeded()
	
	-- Create game state manager
	scenes.menu = MenuScene()
	
	-- Create Scene
	sceneManager:setCurrentScene(scenes.menu)
end

function playdate.update()
	gfx.sprite.redrawBackground()

	-- Random Seed (for generating random numbers)
	math.randomseed(playdate.getSecondsSinceEpoch())

	-- Game Update

	playdate.graphics.animation.blinker.updateAll()
	timer.updateTimers()
	sprite.update()
	frameTimer.updateTimers()

	-- State management
	
	updateScenes()
	
	playdate.drawFPS(10, 10)
		
end

function isGameSceneOver()
	return scenes.game.gameState == gameStates.ended
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

-- Start Game

initialize()

import "engine.lua"
import "scenes/scenes"
import "sprites/lib"
import "utils/level"
import "notify"
import "config"

local acceptsRestart = false


function initialize()
	gfx.setFont(gfx.font.new("fonts/Sans Bold/Cyberball"))
	createLevelPathIfNeeded()
	
	-- Create game state manager
	scenes.menu = MenuScene()
	
	-- Create Scene
	sceneManager:setCurrentScene(scenes.menu)
end

function playdate.update()

	-- Random Seed (for generating random numbers)
	math.randomseed(playdate.getSecondsSinceEpoch())

	-- Game Update

	timer.updateTimers()
	Sprite.update()
	frameTimer.updateTimers()

	-- State management
	
	updateScenes()
end

function onMenuScene()
	if buttons.isAButtonJustPressed() then
		
	end
end

function isGameSceneOver()
	return scenes.game.gameState == gameStates.ended
end

function transitionToGameOverScene()
	sceneManager:switchScene(scenes.gameover, function () end)
end

function onGameOverScene()
	if buttons.isAButtonPressed() then
		-- Perform transition
		
	end
end

function updateScenes()
	
	if sceneManager.currentScene == scenes.menu then
		onMenuScene()
	end
	
	if sceneManager.currentScene == scenes.game then
		if isGameSceneOver() then
			transitionToGameOverScene()
		end
	end
	
	if sceneManager.currentScene == scenes.gameover then
		onGameOverScene()
	end
end

-- Start Game

initialize()

import "engine.lua"
import "scenes/lib"
import "sprites/lib"
import "notify"

local sceneManager = nil
local gameScene = nil
local menuScene = nil
local gameOverScene = nils
local acceptsRestart = false

function initialize()
	-- Create game state manager
	menuScene = MenuScene()
	
	sceneManager = SceneManager()
	
	-- Create Scene
	sceneManager:setCurrentScene(menuScene)
end

function playdate.update()

	-- Random Seed (for generating random numbers)
	math.randomseed(playdate.getSecondsSinceEpoch())

	-- Game Update

	timer.updateTimers()
	Sprite.update()

	-- State management
	
	updateScenes()
end

function onMenuScene()
	if buttons.isAButtonJustPressed() then
		
		gameScene = GameScene()
		gameOverScene = GameOverScene()
		
		sceneManager:switchScene(gameScene, function () end)
	end
end

function isGameSceneOver()
	return gameScene.gameState == gameStates.ended
end

function transitionToGameOverScene()
	sceneManager:switchScene(gameOverScene, function () end)
end

function onGameOverScene()
	if buttons.isAButtonPressed() then
		-- Perform transition
		sceneManager:switchScene(gameScene, function () end)
	end
end

function updateScenes()
	
	if sceneManager.currentScene == menuScene then
		onMenuScene()
	end
	
	if sceneManager.currentScene == gameScene then
		if isGameSceneOver() then
			transitionToGameOverScene()
		end
	end
	
	if sceneManager.currentScene == gameOverScene then
		onGameOverScene()
	end
end

-- Start Game

initialize()

import "engine.lua"
import "scenes/lib"
import "sprites/lib"
import "notify"

local sceneManager = nil
local gameScene = nil
local gameOverScene = nils
local acceptsRestart = false

function initialize()
	-- Create game state manager
	gameScene = GameScene()
	gameOverScene = GameOverScene()
	
	sceneManager = SceneManager()
	
	-- Create Scene
	sceneManager:setCurrentScene(gameScene)
end

function playdate.update()

	-- Random Seed (for generating random numbers)
	math.randomseed(playdate.getSecondsSinceEpoch())

	-- Game Update

	playdate.timer.updateTimers()
	Sprite.update()

	-- State management
	
	if sceneManager.currentScene == gameScene 
			and gameScene.gameState == gameStates.ended then
		sceneManager:switchScene(gameOverScene, function () acceptsRestart = true end)
	end
	
	if sceneManager.currentScene == gameOverScene and acceptsRestart then
		-- Restart game upon pressing A
		if buttons.isAButtonJustPressed() then
			-- Perform transition
			acceptsRestart = false
			sceneManager:switchScene(gameScene, function () end)
		end
	end
end

-- Start Game

initialize()

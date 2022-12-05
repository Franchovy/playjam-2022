import "engine.lua"
import "scenes/lib"
import "sprites/lib"
import "notify"

local soundFile = nil
local sceneManager = nil
local game = nil

function initialize()
	-- Create game state manager
	game = Game()
	
	game:start()
end

class("Game").extends()

gameState = {
	lobby = 0,
	playing = 1,
	ended = 2,
}

function Game:init() 
	-- Update game state
	
	self.state = gameState.lobby
	
	self.gameScene = GameScene()
	self.gameOverScene = GameOverScene()
	
	---------------
	-- GRAPHICS

	sceneManager = SceneManager()
	-- Create Scene
	sceneManager:setCurrentScene(self.gameScene)
	
	-- Create Sound fileplayer for background music
	soundFile = sound.fileplayer.new("music/music_main")

	-- Load background music
	
	soundFile:play(0)
	soundFile:pause()
end

function Game:start()
	-- Clear any previous displays
	
	-----------------
	-- Audio
	soundFile:play(0)
	
	-----------------
	-- Graphics
	
	-- If switching from GameOver
	if sceneManager.currentScene.type == sceneTypes.gameOver then
		-- Perform transition
		sceneManager:switchScene(self.gameScene, function () end)
	end
	
	self.state = gameState.playing
end


function Game:ended()
	
	soundFile:play(0)
	
	-- Perform transition to game over scene
	sceneManager:switchScene(self.gameOverScene, function () end)
	
	self.state = gameState.ended
end

function playdate.update()

	-- Random Seed (for generating random numbers)
	math.randomseed(playdate.getSecondsSinceEpoch())

	-- Game Update

	playdate.timer.updateTimers()
	Sprite.update()

	-- State Management
	if notify.playerHasDied then
		game:ended()
		notify.playerHasDied = false
	end
	
	if game.state == gameState.ended then
		-------------------
		-- On game finished
		
		if notify.gameRestart then
			game:start()
			notify.gameRestart = false
		end
	end
end

-- Start Game

initialize()

import "engine.lua"
import "scenemanager"
import "scenes/lib"
import "sprites/lib"


local wheel = nil
local floors = {}
local coins = {} --new
local game = nil
local soundFile = nil
local sceneManager = nil

local textImageScore=nil --new

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
	
	---------------
	-- GRAPHICS

	sceneManager = SceneManager()
	
	-- Create Scene
	sceneManager:setCurrentScene(GameScene)

	-- Create Player sprite

	wheel = Wheel.new(gfx.image.new("images/wheel1"))
	
	-- Draw Score Text
	
	local imageScore = gfx.image.new(30, 30)
	textImageScore = gfx.sprite.new(imageScore)
	
	gfx.pushContext(imageScore)
	gfx.drawTextAligned(wheel.score, imageScore.width / 2, imageScore.height / 2, textAlignment.center)
	gfx.popContext()
	
	textImageScore:moveTo(imageScore.width/2, imageScore.height/2)
	textImageScore:setIgnoresDrawOffset(true)
	textImageScore:add()

	-- Create Coin sprites
	for i=1,10 do
		table.insert(coins, Coin.new(gfx.image.new("images/coin")))
	end
	
	-- Create Obstacle sprites
	for i=0,28 do
		table.insert(floors, Floor.new(gfx.image.new(40, 40)))
	end
	
	-- Create Sound fileplayer for background music
	soundFile = sound.fileplayer.new("music/weezer")

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
	if sceneManager.currentScene.sceneType == sceneTypes.gameOver then
		-- Perform transition
		sceneManager:switchScene(GameScene)
	end
	
	-- Set Screen position to start
	gfx.setDrawOffset(0, 0)
	
	-- Reset sprites
	
	wheel:onGameStart()
	
	-- Position Sprites

	wheel:add()
	wheel:moveTo(80, 100)
	
	-- Actual Floor
	--floors[1]:setSize(1000, 20)
	floors[1]:moveTo(30, 200)
	
	-- Obstacles, spread through level
	local previousObstacleX = 20
	for i=2,#floors do
		local randY = math.random(20, 140)
		local randX = math.random(20, 420)
		local newX = previousObstacleX + randX
		previousObstacleX = newX
		floors[i]:moveTo(newX, 240 - randY)
	end

	-- Coins, spread through level
	for i=1,#coins do
		coins[i]:moveTo(150*i,200)
	end
	
	-- Setup background
	local backgroundImage = gfx.image.new("images/background")
	-- Background drawing callback - draws background behind sprites
	gfx.sprite.setBackgroundDrawingCallback(
		function(x, y, width, height)
			gfx.setClipRect(x, y, width, height)
			backgroundImage:draw(0, 0)
			gfx.clearClipRect()
		end
	)
	
	self.state = gameState.playing
end


function Game:ended()
	
	--------------
	-- Audio
	
	soundFile:play(0)
	
	--------------
	-- Graphics
	
	-- Perform transition to game over scene
	sceneManager:switchScene(GameOverScene)
	
	self.state = gameState.ended
end

function playdate.update()

	-- Random Seed (for generating random numbers)
	math.randomseed(playdate.getSecondsSinceEpoch())

	-- Game Update

	playdate.timer.updateTimers()
	gfx.sprite.update()
	--gfx.animation.blinker.updateAll()
	
	-- Update screen position
	
	local drawOffset = gfx.getDrawOffset()
	local relativeX = wheel.x + drawOffset
	--print(relativeX) -new
	if relativeX > 150 then
		gfx.setDrawOffset(-wheel.x + 150, 0)
	elseif relativeX < 80 then
		gfx.setDrawOffset(-wheel.x + 80, 0)
	end

	-- Game State checking
	
	if wheel.hasJustDied then
		game:ended()
	end
	
	if game.state == gameState.ended then
		-------------------
		-- On game finished
		
		if buttons.isAButtonPressed() then
			game:start()
		end
	end

	-- Update image score

	local imageScore = gfx.image.new(30, 30)

	gfx.pushContext(imageScore)

	gfx.drawTextAligned(wheel.score, imageScore.width / 2, imageScore.height / 2, textAlignment.center)
	gfx.popContext()
	
	textImageScore:moveTo(imageScore.width/2, imageScore.height/2)
	textImageScore:setIgnoresDrawOffset(true)
	textImageScore:setImage(imageScore)

end

-- Start Game

initialize()

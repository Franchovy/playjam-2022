import "engine.lua"
import "sprites/lib"


local wheel = nil
local floors = {}
local game = nil
local soundFile = nil

function initialize()
	-- Create Sprites

	wheel = Wheel.new(gfx.image.new("images/wheel1"))
	
	-- Create Obstacle sprites
	for i=0,28 do
		table.insert(floors, Floor.new(gfx.image.new(40, 40)))
	end

	-- Create Sound fileplayer for background music
	soundFile = sound.fileplayer.new("music/weezer")
	
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
	self.state = gameState.lobby
	
	-- Draw Game Over text (without adding it to scene)
	
	local image = gfx.image.new(200, 80)
	self.gameOverTextImage = gfx.sprite.new(image)
	
	gfx.pushContext(image)
	gfx.drawTextAligned("*Game Over*", image.width / 2, image.height / 2, textAlignment.center)
	gfx.popContext()
	
	self.gameOverTextImage:moveTo(200, 120)
	self.gameOverTextImage:setIgnoresDrawOffset(true)
	
	-- Load background music
	
	soundFile:play(0)
	soundFile:pause()
end

function Game:start()
	-- Clear any previous displays
	
	self.gameOverTextImage:remove()
	
	-----------------
	-- Audio
	soundFile:play(0)
	
	-----------------
	-- Graphics
	
	-- Set Screen position to start
	gfx.setDrawOffset(0, 0)
	
	-- Reset sprites
	
	wheel:onGameStart()
	
	-- Position Sprites

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
	
	self.gameOverTextImage:add()

	self.state = gameState.ended
end

function playdate.update()

	-- Random Seed (for generating random numbers)
	math.randomseed(playdate.getSecondsSinceEpoch())

	-- Game Update

	playdate.timer.updateTimers()
	gfx.sprite.update()
	
	-- Update screen position
	
	local drawOffset = gfx.getDrawOffset()
	local relativeX = wheel.x + drawOffset
	print(relativeX)
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
		
		return
	end
end

-- Start Game

initialize()

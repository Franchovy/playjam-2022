import "engine.lua"
import "sprites/lib"


local wheel = nil
local floors = {}

function initialize()
	-- Create Sprites

	wheel = Wheel.new(gfx.image.new("images/wheel1"))
	
	-- Create Obstacle sprites
	for i=0,18 do
		table.insert(floors, Floor.new(gfx.image.new(40, 40)))
	end

	Game:start()
end

class("Game").extends()

function Game:start()
	-- Position Sprites

	wheel:moveTo(80, 100)
	
	-- Actual Floor
	floors[1]:setSize(1000, 20)
	floors[1]:moveTo(10, 200)
	
	-- Obstacles, spread through level
	local previousObstacleX = 400
	for i=2,#floors do
		local randY = math.random(20, 180)
		local randX = math.random(40, 420)
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
end

function playdate.update()

	-- Random Seed (for generating random numbers)
	math.randomseed(playdate.getSecondsSinceEpoch())

	-- Game Update

	playdate.timer.updateTimers()
	gfx.sprite.update()

	-- Draw text (debug)

	gfx.drawText("Acceleration Mode", 20, 20)
end

-- Start Game

initialize()

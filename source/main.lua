import "engine.lua"
import "sprites/lib"


local wheel = nil
local floor = nil
local obstacle = nil


function initialize()
	-- Create Sprites
	
	wheel = Wheel.new(gfx.image.new("images/wheel1"))
	floor = Floor.new(gfx.image.new(800, 20))
	obstacle = Floor.new(gfx.image.new(60, 60))
	
	-- Draw Sprites
	
	-- Position Sprites
	
	wheel:moveTo(80, 100)
	floor:moveTo(400, 230)
	obstacle:moveTo(500, 210)
	
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
	
	-- Game Update
	
	playdate.timer.updateTimers()
	gfx.sprite.update()
	
	-- Draw text (debug)
	
	gfx.drawText("Acceleration Mode", 20, 20)
end

-- Start Game

initialize()
import "engine.lua"
import "sprites/lib"


local wheel = nil
local floor = nil
local obstacle = nil

function initialize()
	
	-- Create Sprites
	
	wheel = Wheel.new(gfx.image.new("images/wheel2"))
	floor = Floor.new(gfx.image.new(400, 20))
	obstacle = Floor.new(gfx.image.new(60, 60))
	
	-- Draw Sprites
	
	function floor:drawWithContext() 
		gfx.fillRect(0, 0, image:getSize())
	end
	
	function obstacle:drawWithContext() 
		gfx.fillRect(0, 0, image:getSize())
	end
	
	-- Position Sprites
	
	wheel:moveTo(80, 100)
	
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
	
	if playdate.buttonIsPressed( playdate.kButtonRight ) then
		wheel:turnRight()
	end
	
	-- Game Update
	
	playdate.timer.updateTimers()
	gfx.sprite.update()
end

-- Start Game

initialize()
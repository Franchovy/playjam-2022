import "engine"

function playdate.update()
	
	-- Game Update
	
	playdate.timer.updateTimers()
	gfx.sprite.update()
end
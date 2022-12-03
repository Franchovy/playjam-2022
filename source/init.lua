
function initialize()
	
	local wheelImage = gfx.image.new("images/wheel")
	wheel = Wheel.new(wheelImage)
	
	wheel.moveTo(360, 80)
end
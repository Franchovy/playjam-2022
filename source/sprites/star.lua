import "playdate"
import "assets"

class("Star").extends(playdate.sprite)

function Star.new()
	return Star()
end

function Star:init()
	Star.super.init(self)
	
	self:setImageTable(kAssetsImages.star)
end

function Star:animate()
	print("Animating star!")
end
import "engine"

class("Boule").extends(Sprite)

MAX_SPEED = 5

function Boule.new()
	return Boule()
end

function Boule:init() 
	Boule.super.init(self, gfx.image.new("images/boule"):scaledImage(2))
end

function Boule:update()
	self:moveBy(MAX_SPEED, 0)
end
import "engine"
import "CoreLibs/timer"
import "components/images"

class('Wind').extends(Sprite)

local windPower = -4
local animationSpeed = 250

function Wind.new() 
	return Wind()
end

function Wind:init()
	Wind.super.init(self)
	
	local image = gfx.image.new(kImages.wind):scaledImage(6, 4)
	self:setImage(image)
	
	self.type = spriteTypes.wind
	self.windPower = windPower
	self:setZIndex(-1)
	self:setCollideRect(0, 0, self:getSize())
	
	self.imageIndex = 1

	local timer = playdate.timer.new(animationSpeed, function() self:manageAnim() end)
	timer.repeats = true
end

function Wind:manageAnim()
	self.imageIndex = (self.imageIndex % 4) + 1
	
	self:setImage(kImages.wind, self.imageIndex)
end

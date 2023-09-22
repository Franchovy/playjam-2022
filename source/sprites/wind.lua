import "engine"
import "CoreLibs/timer"
import "components/images"

class('Wind').extends(Sprite)

local windPower = -4
local animationSpeed = 250

local images = {}

function Wind.new() 
	return Wind()
end

function Wind:init()
	Wind.super.init(self)
	
	images = getSpriteImagesScaled()
	
	local image = gfx.image.new(images[1])
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
	
	self:setImage(images[self.imageIndex])
end

function getSpriteImagesScaled()
	local scaledImages = {}
	local images = getImageTable(kImages.wind, 4)
	for _, v in pairs(images) do
		table.insert(scaledImages, v:scaledImage(6, 4))
	end
	return scaledImages
end
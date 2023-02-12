import "engine"
import "CoreLibs/timer"
import "components/images"

class('Wind').extends(Sprite)

local windPower = -4

function Wind.new() 
	return Wind()
end

function Wind:init()
	local image = getImage(kImages.wind[1]):scaledImage(6, 4)
	Wind.super.init(self, image)
	
	self.type = spriteTypes.wind
	
	self.windPower=windPower
	self.imageIndex = 1

	self:setCollideRect(0, 0, self:getSize())
	
	self:setZIndex(-1)

	self.animBegin=false
end

function Wind:update()
	
	if(self.animBegin==false) then
		self.animBegin=true
		local transitionTime=250
		local t = playdate.timer.new(transitionTime, 0, 1, easingFunctions.linear)

		t.timerEndedCallback= function(timer)
			self:manageAnim()
		end
	end
end

function Wind:manageAnim()
	self.imageIndex = (self.imageIndex % 4) + 1
	local image=getImage(kImages.wind[self.imageIndex]):scaledImage(6, 4)
	
	self:setImage(image)

	self.animBegin=false
end

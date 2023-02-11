import "engine"
import "CoreLibs/timer"

class('Wind').extends(Sprite)

function Wind.new(image,windPower) 
	return Wind(image,windPower)
end

function Wind:init(image,windPower)
	Wind.super.init(self, image)
	self.type = spriteTypes.wind
	
	self.windPower=windPower
	self.currentSprite=0

	if(self.windPower>0) then
		self.currentSprite=1
	elseif(self.windPower<0) then
		self.currentSprite=4
	end	
	
	self:setCollideRect(0, 0, self:getSize())
	
	self:setZIndex(-1)

	self.animBegin=false
end

function Wind:update()
	
	if(self.animBegin==false) then
		self.animBegin=true
		local trnasitionTime=250
		local t = playdate.timer.new(trnasitionTime, 0, 1, easingFunctions.linear)

		t.timerEndedCallback= function(timer)
			self:manageAnim()
		end
	end
end

function Wind:manageAnim()
	if(self.currentSprite>4) then
		self.currentSprite=1
	elseif(self.currentSprite<1) then
		self.currentSprite=4
	end

	if(self.windPower>0) then
		self.currentSprite+=1
	elseif(self.windPower<0) then
		self.currentSprite-=1
	end
	local image=gfx.image.new(images.wind[self.currentSprite]):scaledImage(6, 4)
	self:setImage(image)

	self.animBegin=false
end

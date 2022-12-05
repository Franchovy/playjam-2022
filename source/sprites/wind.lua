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

	-- local trnasitionTime=250
	-- local t = playdate.timer.new(trnasitionTime, 0, 1, easingFunctions.linear)
	-- --t.reverses = true
	-- t.repeats = true
	-- --t.reverseEasingFunction = easingFunctions.outQuad
	-- -- t.updateCallback = function(timer)
	-- -- 	print("Time:" .. tostring(timer.value))
	-- -- 	if(timer.value>0.9 and self.animUpdated==false) then
	-- -- 		--print("Time:" .. tostring(timer.value))
	-- -- 		self:manageAnim()
	-- -- 		self.animUpdated=true
	-- -- 	end
	-- -- end

	-- t.timerEndedCallback= function(timer)
	-- 	--print("Time:" .. tostring(timer.value))
	-- 	self:manageAnim()
	-- end

end

function Wind:update()
	
	if(self.animBegin==false) then
		self.animBegin=true
		local trnasitionTime=250
		local t = playdate.timer.new(trnasitionTime, 0, 1, easingFunctions.linear)
		--t.reverses = true
		--t.repeats = true
		--t.reverseEasingFunction = easingFunctions.outQuad
		-- t.updateCallback = function(timer)
		-- 	print("Time:" .. tostring(timer.value))
		-- 	if(timer.value>0.9 and self.animUpdated==false) then
		-- 		--print("Time:" .. tostring(timer.value))
		-- 		self:manageAnim()
		-- 		self.animUpdated=true
		-- 	end
		-- end

		t.timerEndedCallback= function(timer)
			--print("Time:" .. tostring(timer.value))
			self:manageAnim()
		end
	end
	-- --timer.performAfterDelay(300, callback, ...)
	

	-- if(self.currentSprite>4) then
	-- 	self.currentSprite=1
	-- elseif(self.currentSprite<1) then
	-- 	self.currentSprite=4
	-- end
	-- local imageName = string.format("images/winds/wind%01d", self.currentSprite)

	-- if(self.windPower>0) then
	-- 	self.currentSprite+=1
	-- elseif(self.windPower<0) then
	-- 	self.currentSprite-=1
	-- end
	-- local image=gfx.image.new(imageName):scaledImage(6, 4)
	-- --self:getImage():load(imageName)
	-- self:setImage(image)
	-- --self:getImage():scaledImage(6, 4)
	

end

function Wind:manageAnim()
	if(self.currentSprite>4) then
		self.currentSprite=1
	elseif(self.currentSprite<1) then
		self.currentSprite=4
	end
	local imageName = string.format("images/winds/wind%01d", self.currentSprite)

	if(self.windPower>0) then
		self.currentSprite+=1
	elseif(self.windPower<0) then
		self.currentSprite-=1
	end
	local image=gfx.image.new(imageName):scaledImage(6, 4)
	--self:getImage():load(imageName)
	self:setImage(image)

	self.animBegin=false
	--self:getImage():scaledImage(6, 4)a
end

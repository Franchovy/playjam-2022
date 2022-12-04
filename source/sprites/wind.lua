import "engine"

class('Wind').extends(Sprite)

function Wind.new(image,windPower) 
	return Wind(image,windPower)
end

function Wind:init(image,windPower)
	Wind.super.init(self, image)
	self.type = "Wind"
	self.windPower=windPower
	-- print(image)
	
	self:setCollideRect(0, 0, self:getSize())
end

-- function Wind:destroy()
-- 	self:remove()
-- end

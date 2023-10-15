import "engine"
import "constant"
import "playdate"
import "utils/periodicBlinker"

class('KillBlock').extends(playdate.sprite)

-- Static instance
-- TODO: Manage lifecycle
local timer, blinker, destroyTimerBlinker

function KillBlock.new(blinkerTimer) 
	return KillBlock()
end

function KillBlock:init()
	KillBlock.super.init(self)
	self.type = kSpriteTypes.killBlock
	print(thisIsMyTestVariable)
	local image = gfx.image.new(kImages.killBlock)
	self:setImage(image)
	self:setCollideRect(0, 0, self:getSize())
	self:setCenter(0, 0)
	
	-- Blinker & Timer
	
	if timer == nil and blinker == nil and destroyTimerBlinker == nil then
		timer, blinker, destroyTimerBlinker = periodicBlinker({onDuration = 50, offDuration = 50, cycles = 8}, 300)
	end
end

function KillBlock:update()
	KillBlock.super.update(self)
	
	if blinker ~= nil then
		local image = self:getImage()
		image:setInverted(blinker.on)
		self:setImage(image)
		self:markDirty()
	end
end
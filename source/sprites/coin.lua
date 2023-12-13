import "engine"
import "constant"

class('Coin').extends(playdate.graphics.sprite)

function Coin.new() 
	return Coin()
end

function Coin:init()
	Coin.super.init(self)
	self.type = kSpriteTypes.coin
	
	local image = playdate.graphics.image.new(kAssetsImages.coin)
	self:setImage(image)
	self:setCenter(0, 0)
	self:setCollideRect(self:getBounds())
	
	self.config = {
		isPicked = false
	}
	
	self:setUpdatesEnabled(false)
	self:setGroupMask(kCollisionGroups.static)
end

function Coin:loadConfig(config)
	self.config.isPicked = config.isPicked
	
	self:setVisible(not self.config.isPicked)
end

function Coin:writeConfig(config)
	config.isPicked = self.config.isPicked
end

function Coin:reset()
	self.config.isPicked = false
	
	self:setVisible(not self.config.isPicked)
end

function Coin:isGrabbed()
	self.config.isPicked = true
	
	self:setVisible(not self.config.isPicked)
end

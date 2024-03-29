import "engine"
import "constant"

local gfx <const> = playdate.graphics

class('Coin').extends(gfx.sprite)

function Coin.new() 
	return Coin()
end

local coinImage
local coinEmptyImage

function Coin:init()
	Coin.super.init(self)
	self.type = kSpriteTypes.coin
	
	if coinImage == nil then
		coinImage = gfx.image.new(kAssetsImages.coin)
		coinEmptyImage = coinImage:copy()
		coinEmptyImage:clear(gfx.kColorClear)
	end
	self:setImage(coinImage)
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
	
	self:updateImage()
end

function Coin:copyConfig(config)
	config.isPicked = self.config.isPicked
end

function Coin:reset()
	self.config.isPicked = false
	
	self:updateImage()
end

function Coin:isGrabbed()
	self.config.isPicked = true
	
	self:updateImage()
end

function Coin:updateImage()
	if self.config.isPicked == true then
		self:setImage(coinEmptyImage)
	elseif self.config.isPicked == false then
		self:setImage(coinImage)
	end
	
	self:markDirty()
end

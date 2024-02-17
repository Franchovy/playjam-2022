import "engine"
import "constant"

local gfx <const> = playdate.graphics
local _gridSize <const> = kGame.gridSize

class('Platform').extends(gfx.sprite)

local platformImage

function Platform.new() 
	return Platform()
end

function Platform:init()
	if platformImage == nil then
		platformImage = gfx.image.new(kAssetsImages.platform)
	end
	
	Platform.super.init(self)
	self.type = kSpriteTypes.platform
	
	self:setBounds(0, 0, _gridSize, _gridSize)
	self:setCenter(0, 0)
	
	self:setOpaque(true)
	
	self:setUpdatesEnabled(false)
	self:setGroupMask(kCollisionGroups.static)
	
	local _, drawBoundsW, drawBoundsH
	function self:draw()
		platformImage:drawTiled(0, 0, drawBoundsW, drawBoundsH)
	end
	function self:updateDrawBounds()
		_, _, drawBoundsW, drawBoundsH = self:getBounds()
	end
	
	self:updateDrawBounds()
end

function Platform:loadConfig(config)
	self:setSize(config.w * _gridSize, config.h * _gridSize)
	
	self:updateDrawBounds()
	self:setCollideRect( 0, 0, self:getSize() )
	self:markDirty()
end

function Platform:copyConfig(config)
	local w, h = self:getSize()
	config.w = w
	config.h = h
end
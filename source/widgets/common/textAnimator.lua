local gfx <const> = playdate.graphics
local geo <const> = playdate.geometry
local _kImageUnflipped <const> = gfx.kImageUnflipped

class("WidgetTextAnimator").extends(Widget)

local highlightWidth <const> = 50
local textHeight

function WidgetTextAnimator:_init()
	self:supply(Widget.deps.animators)
	self:supply(Widget.deps.frame)
	
	self.images = {}
	
	self:createSprite(kZIndex.overlay)
	self.sprite:setIgnoresDrawOffset(false)
end

function WidgetTextAnimator:_load()
	local text = self.config.text
	textHeight = gfx.getFont():getHeight()
	
	self.images.text = gfx.imageWithText(text, 400, textHeight)
	
	local frame = geo.rect.new(0, 0, self.images.text:getSize())
	self:setFrame(frame)
	
	self.images.textInverted = self.images.text:invertedImage()
	
	self.beginAnimation = function()
		self.animators.highlightOffset = gfx.animator.new(5000, self.images.text:getSize(), -highlightWidth)
	end
	
	self.setPositionCentered = function(x, y)
		self.sprite:moveTo(x, y)
	end
end

function WidgetTextAnimator:_draw(frame, rect)
	local animatorValue = self:getAnimatorValue(self.animators.highlightOffset)
	print(animatorValue)
	self.images.text:draw(frame.x, frame.y)
	self.images.textInverted:draw(frame.x + animatorValue, frame.y, _kImageUnflipped, 0, 0, 200, 100)
end

function WidgetTextAnimator:_update()
	if self:isAnimating() == true then
		self.sprite:markDirty()
	end	
end
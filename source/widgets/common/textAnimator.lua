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
	
	self.blinker = gfx.animation.blinker.new(200, 50, true)
	self.blinker:stop()
	
	self.beginAnimation = function()
		self:setVisible(true)
		self.blinker:startLoop()
	end
	
	self.endAnimation = function()
		self:setVisible(false)
		self.blinker:stop()
	end
	
	self.setPositionCentered = function(x, y)
		self.sprite:moveTo(x, y)
	end
end

function WidgetTextAnimator:_draw(frame, rect)
	if self.blinker.on then
		self.images.text:draw(frame.x, frame.y)
	else
		self.images.textInverted:draw(frame.x, frame.y)
	end
end

function WidgetTextAnimator:_update()
	if self.blinker.hasJustChanged then
		self.sprite:markDirty()
	end	
end
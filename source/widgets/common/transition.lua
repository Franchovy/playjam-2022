local gfx <const> = playdate.graphics
local easing <const> = playdate.easingFunctions
class("WidgetTransition").extends(Widget)

function WidgetTransition:_init()
	self:supply(Widget.deps.state)
	self:supply(Widget.deps.animators)
	self:supply(Widget.deps.samples)
	
	self:createSprite(kZIndex.transition)
	
	self:setStateInitial(1, { "open", "closed" })

	self.images = {}	
	self.painters = {}
	self.animators = {}
	self.signals = {}
end

function WidgetTransition:_load()
	self.images.background = gfx.image.new(kAssetsImages.transitionBackground)
	self.images.foreground = gfx.image.new(kAssetsImages.transitionForeground)
	self.images.wheel = gfx.imagetable.new(kAssetsImages.wheel):getImage(1):invertedImage()
	
	setCurrentFont(kAssetsFonts.twinbee2x)
	self.images.text = gfx.imageWithText("LOADING...", 250, 25):invertedImage()
	
	self.painters.screen = Painter(function(rect)
		gfx.setColor(gfx.kColorBlack)
		gfx.fillRect(rect.x, rect.y, rect.w, rect.h)
		
		gfx.setColor(gfx.kColorWhite)
		gfx.setDitherPattern(0.9, gfx.image.kDitherTypeVerticalLine)
		gfx.fillRect(rect.x, rect.y, rect.w, rect.h)
		
		self.images.background:drawFaded(rect.x, rect.y, 0.5, gfx.image.kDitherTypeDiagonalLine)
		self.images.foreground:drawFaded(rect.x, rect.y, 0.2, gfx.image.kDitherTypeDiagonalLine)
		
		gfx.setColor(gfx.kColorBlack)
		gfx.setDitherPattern(0.2, gfx.image.kDitherTypeBayer8x8)
		gfx.fillRect(rect.x, rect.y, rect.w, rect.h)
	end)
	
	self.painters.wheel = Painter(function(rect)
		self.images.wheel:draw(rect.x, rect.y)
	end)
	
	self.painters.text = Painter(function(rect)
		self.images.text:draw(rect.x, rect.y)
	end)
	
	self:loadSample(kAssetsSounds.transitionSwoosh, 0.8, "swoosh")
	self:loadSample(kAssetsSounds.transitionSlam, 0.8, "slam")
	self:loadSample(kAssetsSounds.transitionOut, 0.8, "out")
	
	self.cover = function(callback)
		self:setVisible(true)
		self:setState(self.kStates.closed)
		
		self.signals.animationFinished = callback
	end
	
	self.uncover = function(callback)
		self:setState(self.kStates.open)
		
		self.signals.animationFinished = function()
			self:setVisible(false)
			
			if callback ~= nil then
				callback()
			end
		end
	end
end

function WidgetTransition:_draw(frame)
	local animatorValue = self:getAnimatorValue(self.animators.animator)
	local rectOffset = Rect.offset(frame, animatorValue, 0)
	self.painters.screen:draw(rectOffset)
	
	if self.config.showLoading == true and (self:isAnimating() == false) and (self.state == self.kStates.closed) then
		local wheelImageSizeW, wheelImageSizeH = self.images.wheel:getSize()
		local rectWheel = Rect.make(frame.x + 25, frame.y + frame.h - wheelImageSizeH - 25, wheelImageSizeW, wheelImageSizeH)
		self.painters.wheel:draw(rectWheel)
		
		local textImageSizeW, textImageSizeH = self.images.text:getSize()
		local rectText = Rect.make(frame.x + 25 + wheelImageSizeW + 15, frame.y + frame.h - 25 - 30, textImageSizeW, textImageSizeH)
		self.painters.text:draw(rectText)
	end
end

function WidgetTransition:_update()
	-- TODO: Update wheel rotation (%12) on every tick, use painter state
	
	if self:wasAnimating() == true then
		gfx.sprite.addDirtyRect(0, 0, 400, 240)
	end
end

function WidgetTransition:_changeState(stateFrom, stateTo)
	if stateFrom == self.kStates.open and stateTo == self.kStates.closed then
		self.animators.animator = gfx.animator.new(400, -400, 0, easing.inQuad, 100)
		self:playSample("swoosh")
		
		self.animators.animator.finishedCallback = function()
			self:playSample("slam")
			
			if self.signals.animationFinished ~= nil then
				self.signals.animationFinished()
				
				gfx.sprite.addDirtyRect(0, 0, 400, 240)
			end
		end
	end
	
	if stateFrom == self.kStates.closed and stateTo == self.kStates.open then
		self.animators.animator = gfx.animator.new(600, 0, -400, easing.inQuint)
		self:playSample("out")
		
		self.animators.animator.finishedCallback = function()
			if self.signals.animationFinished ~= nil then
				self.signals.animationFinished()
				
				gfx.sprite.addDirtyRect(0, 0, 400, 240)
			end
		end
	end
end
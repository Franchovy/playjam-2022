class("WidgetTransition").extends(Widget)

function WidgetTransition:init(config)
	self.config = config or {}
	
	self:supply(Widget.deps.state)
	self:supply(Widget.deps.animators)
	self:supply(Widget.deps.samples)
	
	self:createSprite(kZIndex.transition)
	
	self:setStateInitial({ open = 1, closed = 2 }, 1)

	self.images = {}	
	self.painters = {}
	self.animators = {}
	self.signals = {}
end

function WidgetTransition:_load()
	self.images.background = playdate.graphics.image.new(kAssetsImages.transitionBackground)
	self.images.foreground = playdate.graphics.image.new(kAssetsImages.transitionForeground)
	self.images.wheel = playdate.graphics.imagetable.new(kAssetsImages.wheel):getImage(1):invertedImage()
	self.images.text = playdate.graphics.imageWithText("LOADING...", 250, 25):scaledImage(2):invertedImage()
	
	self.painters.screen = Painter(function(rect)
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.fillRect(rect.x, rect.y, rect.w, rect.h)
		
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.setDitherPattern(0.9, playdate.graphics.image.kDitherTypeVerticalLine)
		playdate.graphics.fillRect(rect.x, rect.y, rect.w, rect.h)
		
		self.images.background:drawFaded(rect.x, rect.y, 0.5, playdate.graphics.image.kDitherTypeDiagonalLine)
		self.images.foreground:drawFaded(rect.x, rect.y, 0.2, playdate.graphics.image.kDitherTypeDiagonalLine)
		
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.setDitherPattern(0.2, playdate.graphics.image.kDitherTypeBayer8x8)
		playdate.graphics.fillRect(rect.x, rect.y, rect.w, rect.h)
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
	
	if self:isAnimating() == true then
		playdate.graphics.sprite.addDirtyRect(0, 0, 400, 240)
	end
end

function WidgetTransition:_changeState(stateFrom, stateTo)
	if stateFrom == self.kStates.open and stateTo == self.kStates.closed then
		self.animators.animator = playdate.graphics.animator.new(400, -400, 0, playdate.easingFunctions.inQuad, 100)
		self:playSample("swoosh")
		
		self.animators.animator.finishedCallback = function()
			self:playSample("slam")
			
			if self.signals.animationFinished ~= nil then
				self.signals.animationFinished()
				--self.signals.animationFinished = nil
			end
		end
	end
	
	if stateFrom == self.kStates.closed and stateTo == self.kStates.open then
		self.animators.animator = playdate.graphics.animator.new(600, 0, -400, playdate.easingFunctions.inQuint)
		self:playSample("out")
		
		self.animators.animator.finishedCallback = function()
			if self.signals.animationFinished ~= nil then
				self.signals.animationFinished()
			end
		end
	end
end
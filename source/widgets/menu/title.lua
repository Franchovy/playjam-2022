import "utils/rect"
import "utils/position"
import "common/painters/background"

class("WidgetTitle").extends(Widget)

function WidgetTitle:init()
	self:supply(Widget.kDeps.update)
	self:supply(Widget.kDeps.animators)
	
	self:setAnimations({
		onFirstOpen = 1,
		toLevelSelect = 2,
		fromLevelSelect = 3
	})
	
	self.images = {}
	self.imagetables = {}
	self.painters = {}
	
	self.index = 0
	self.tick = 0
end

function WidgetTitle:_load()
	self.imagetables.particles = playdate.graphics.imagetable.new(kAssetsImages.particles)
	self.imagetables.wheel = playdate.graphics.imagetable.new(kAssetsImages.wheel):scaled(2)
	self.images.backgroundImage = playdate.graphics.image.new(kAssetsImages.background)
	self.images.backgroundImage2 = playdate.graphics.image.new(kAssetsImages.background2)
	self.images.backgroundImage3 = playdate.graphics.image.new(kAssetsImages.background3)
	self.images.backgroundImage4 = playdate.graphics.image.new(kAssetsImages.background4)
	self.images.textImage = playdate.graphics.imageWithText("WHEEL RUNNER", 400, 100):scaledImage(3)
	self.images.pressStart = playdate.graphics.imageWithText("PRESS A", 200, 60):scaledImage(2)
	
	-- Painter Button
	
	local painterButtonFill = Painter(function(rect, state)
		if state.tick == 0 then
			-- press a button fill
			playdate.graphics.setColor(playdate.graphics.kColorWhite)
			playdate.graphics.setDitherPattern(0.8, playdate.graphics.image.kDitherTypeDiagonalLine)
			playdate.graphics.fillRoundRect(rect.x, rect.y, rect.w, rect.h, 6)
		else
			-- press a button fill
			playdate.graphics.setColor(playdate.graphics.kColorWhite)
			playdate.graphics.setDitherPattern(0.2, playdate.graphics.image.kDitherTypeDiagonalLine)
			playdate.graphics.fillRoundRect(rect.x, rect.y, rect.w, rect.h, 6)
		end
	end)
	
	local painterButtonOutline = Painter(function(rect, state)
		if state.tick == 0 then
			-- press a button outline
			playdate.graphics.setColor(playdate.graphics.kColorBlack)
			playdate.graphics.setDitherPattern(0.2, playdate.graphics.image.kDitherTypeDiagonalLine)
			playdate.graphics.setLineWidth(3)
			playdate.graphics.drawRoundRect(rect.x, rect.y, rect.w, rect.h, 6)
		else
			-- press a button outline
			playdate.graphics.setColor(playdate.graphics.kColorBlack)
			playdate.graphics.setLineWidth(3)
			playdate.graphics.drawRoundRect(rect.x, rect.y, rect.w, rect.h, 6)
		end
	end)
	
	local painterButtonPressStart = Painter(function(rect, state)
		if state.tick == 0 then
			-- press a text
			self.images.pressStart:drawFaded(rect.x, rect.y, 0.3, playdate.graphics.image.kDitherTypeDiagonalLine)
		else
			-- press a text
			self.images.pressStart:draw(rect.x, rect.y)
		end
	end)
	
	self.painters.painterButton = Painter(function(rect, state) 
		painterButtonFill:draw(rect, state)
		painterButtonOutline:draw(rect, state)
		
		local imageSizePressStartW, imageSizePressStartH = self.images.pressStart:getSize()
		local rectButtonText = Rect.with(Rect.offset(rect, 15, 5), { w = imageSizePressStartW, h = imageSizePressStartH })
		painterButtonPressStart:draw(rectButtonText, state)
	end, { alwaysRedraw = true })
	
	-- Painter Background
	
	self.painterBackground1 = Painter(function(rect, state)
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.fillRect(rect.x, rect.y, rect.w, rect.h)
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.setDitherPattern(0.4, playdate.graphics.image.kDitherTypeDiagonalLine)
		playdate.graphics.fillRect(rect.x, rect.y, rect.w, rect.h)
	end)
	
	self.painterBackground2 = Painter(function(rect, state)
		-- background - right hill
		local offsetRect = Rect.offset(rect, 0, -10)
		self.images.backgroundImage3:drawFaded(offsetRect.x, offsetRect.y, 0.4, playdate.graphics.image.kDitherTypeBayer8x8)
	end)
	
	self.painterBackground3 = Painter(function(rect, state)
		local offsetRect = Rect.offset(rect, 5, 0)
		-- background - flashing lights
		if state.tick == 0 then
			self.images.backgroundImage2:drawFaded(offsetRect.x, offsetRect.y, 0.6, playdate.graphics.image.kDitherTypeDiagonalLine)
		else
			self.images.backgroundImage2:invertedImage():drawFaded(offsetRect.x, offsetRect.y, 0.3, playdate.graphics.image.kDitherTypeDiagonalLine)
		end
	end)
	
	self.painterBackground4 = Painter(function(rect, state)
		local offsetRect = Rect.offset(rect, -20, 120)
		-- background - left hill
		self.images.backgroundImage4:drawFaded(offsetRect.x, offsetRect.y, 0.9, playdate.graphics.image.kDitherTypeBayer4x4)
	end)
	
	self.painterBackgroundAssets = Painter(function(rect, state)
		local offsetRect = Rect.offset(rect, 200, 30)
		-- background assets (coin, platforms, kill-block)
		self.images.backgroundImage:draw(offsetRect.x, offsetRect.y)
	end)
	
	-- Painter Text
	
	local painterTitleRectangleOutline = Painter(function(rect, state)
		-- title rectangle outline
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.fillRect(0, 0, rect.w, rect.h)
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.setDitherPattern(0.3, playdate.graphics.image.kDitherTypeDiagonalLine)
		playdate.graphics.fillRect(rect.x, rect.y, rect.w, rect.h)
	end)
	
	local painterTitleRectangleFill = Painter(function(rect, state)
		-- title rectangle fill
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.setDitherPattern(0.3, playdate.graphics.image.kDitherTypeDiagonalLine)
		playdate.graphics.fillRect(rect.x, rect.y, rect.w, rect.h)
	end)
	
	local painterTitleText = Painter(function(rect, state)
		self.images.textImage:draw(0, 0)
	end)
	
	self.painters.painterTitle = Painter(function(rect, state)
		painterTitleRectangleOutline:draw(Rect.at(rect, 0, 0))
		painterTitleRectangleFill:draw(Rect.inset(Rect.at(rect, 0, 0), 0, 10))
		local titleTextSizeW, titleTextSizeH = self.images.textImage:getSize()
		painterTitleText:draw({x = 40, y = 15, w = titleTextSizeW, h = titleTextSizeH })
	end)
	
	self.painters.painterWheel = Painter(function(rect, state)
		self.imagetables.particles:getImage((state.index % 36) + 1):scaledImage(2):draw(10, -70)
		
		self.imagetables.wheel:getImage((-state.index % 12) + 1):draw(140, 0)
	end, { alwaysRedraw = true })
end

function WidgetTitle:_animate(animation, queueFinishedCallback)
	if animation == self.kAnimations.onFirstOpen then
		self.animators.animator1 = playdate.graphics.animator.new(800, 240, 0, playdate.easingFunctions.outExpo, 100)
		self.animators.animator2 = playdate.graphics.animator.new(800, 150, 0, playdate.easingFunctions.outExpo, 500)
		self.animators.animator3 = playdate.graphics.animator.new(800, 150, 0, playdate.easingFunctions.outCirc, 1000)
		self.animators.animatorWheel = playdate.graphics.animator.new(
			800, 
			playdate.geometry.point.new(-200, -30), 
			playdate.geometry.point.new(0, 0), 
			playdate.easingFunctions.outQuad, 
			800
		)
		
		-- Placeholder animator for use on transition out
		self.animators.animatorOut = playdate.graphics.animator.new(0, 0, 0, playdate.easingFunctions.outCirc, 0)
		self.animators.animatorOutWheel = playdate.graphics.animator.new(0, playdate.geometry.point.new(0, 0), playdate.geometry.point.new(0, 0), playdate.easingFunctions.outCirc, 0)
		
		queueFinishedCallback(1800)
	elseif animation == self.kAnimations.fromLevelSelect then
		self.animators.animatorOut = playdate.graphics.animator.new(
			800, 
			math.min(240, self.animators.animatorOut:currentValue()), 
			0, 
			playdate.easingFunctions.outExpo, 
			200
		)
		self.animators.animatorOutWheel = playdate.graphics.animator.new(0, playdate.geometry.point.new(0, 0), playdate.geometry.point.new(0, 0), playdate.easingFunctions.outCirc, 0)
		self.animators.animatorWheel:reset()
		
		queueFinishedCallback(1000)
	elseif animation == self.kAnimations.toLevelSelect then
		self.animators.animatorOut = playdate.graphics.animator.new(
			800, 
			math.max(0, self.animators.animatorOut:currentValue()), 
			240, 
			playdate.easingFunctions.inExpo, 200
		)
		self.animators.animatorOutWheel = playdate.graphics.animator.new(
			800, 
			playdate.geometry.point.new(0, 0), 
			playdate.geometry.point.new(450, 100),  
			playdate.easingFunctions.inQuad, 
			500
		)
		
		queueFinishedCallback(1300)
	end
end

function WidgetTitle:_draw(frame, rect)	
	local animationValue = self.animators.animator1:currentValue() + self.animators.animatorOut:currentValue()
	
	local rectOffsetTop = Rect.offset(frame, 0, -20 - animationValue)
	local rectOffsetLeft = Rect.offset(frame, -animationValue, -20)
	local rectOffsetRight = Rect.offset(frame, animationValue, -20)
	self.painterBackground1:draw(rectOffsetTop)
	self.painterBackground2:draw(rectOffsetRight)
	self.painterBackground3:draw(rectOffsetTop, { tick = self.tick })
	self.painterBackground4:draw(rectOffsetLeft)
	self.painterBackgroundAssets:draw(rectOffsetRight)
	
	local animationWheelValue = self.animators.animatorWheel:currentValue():offsetBy(self.animators.animatorOutWheel:currentValue().x, self.animators.animatorOutWheel:currentValue().y)
	self.painters.painterWheel:draw({x = animationWheelValue.x - 60, y = 30 + animationWheelValue.y, w = 280, h = 120}, { index = self.index % 36 })
	
	local titleRect = Rect.with(Rect.offset(frame, 0, 130 + self.animators.animator2:currentValue() + self.animators.animatorOut:currentValue()), { h = 57 })
	self.painters.painterTitle:draw(titleRect)
	
	local buttonRect = Rect.offset(Rect.with(Rect.center(Rect.size(160, 27), frame), { y = 200 }), 0, self.animators.animator3:currentValue() + self.animators.animatorOut:currentValue())
	self.painters.painterButton:draw(buttonRect, { tick = self.tick })
end

function WidgetTitle:_update()
	self.index += 2
	
	if self.index % 40 > 32 then
		self.tick = self.tick == 0 and 1 or 0
	end
	
	playdate.graphics.sprite.addDirtyRect(0, 0, 400, 240)
end

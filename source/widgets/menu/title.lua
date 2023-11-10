import "utils/rect"
import "utils/position"

class("WidgetTitle").extends(Widget)

WidgetLevelSelect.kAnimations = {
	animateIn = 1,
	animateOut = 2,
	animateBackIn = 3
}

function WidgetTitle:init()
	self.animators = {}
	
	self.images = {}
	self.painters = {}
	
	self.index = 0
	self.tick = 0
end

function WidgetTitle:_load()
	self.images.imagetable = playdate.graphics.imagetable.new(kAssetsImages.particles)
	self.images.wheelImageTable = playdate.graphics.imagetable.new(kAssetsImages.wheel):scaled(2)
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
			playdate.graphics.fillRoundRect(0, 0, rect.w, rect.h, 6)
		else
			-- press a button fill
			playdate.graphics.setColor(playdate.graphics.kColorWhite)
			playdate.graphics.setDitherPattern(0.2, playdate.graphics.image.kDitherTypeDiagonalLine)
			playdate.graphics.fillRoundRect(0, 0, rect.w, rect.h, 6)
		end
	end)
	
	local painterButtonOutline = Painter(function(rect, state)
		if state.tick == 0 then
			-- press a button outline
			playdate.graphics.setColor(playdate.graphics.kColorBlack)
			playdate.graphics.setDitherPattern(0.2, playdate.graphics.image.kDitherTypeDiagonalLine)
			playdate.graphics.setLineWidth(3)
			playdate.graphics.drawRoundRect(0, 0, rect.w, rect.h, 6)
		else
			-- press a button outline
			playdate.graphics.setColor(playdate.graphics.kColorBlack)
			playdate.graphics.setLineWidth(3)
			playdate.graphics.drawRoundRect(0, 0, rect.w, rect.h, 6)
		end
	end)
	
	local painterButtonPressStart = Painter(function(rect, state)
		if state.tick == 0 then
			-- press a text
			self.images.pressStart:drawFaded(0, 0, 0.3, playdate.graphics.image.kDitherTypeDiagonalLine)
		else
			-- press a text
			self.images.pressStart:draw(0, 0)
		end
	end)
	
	self.painters.painterButton = Painter(function(rect, state) 
		painterButtonFill:draw({ x = 0, y = 0, w = rect.w, h = rect.h }, state)
		painterButtonOutline:draw({ x = 0, y = 0, w = rect.w, h = rect.h }, state)
		
		local imageSizePressStartW, imageSizePressStartH = self.images.pressStart:getSize()
		painterButtonPressStart:draw({x = 15, y = 5, w = imageSizePressStartW, h = imageSizePressStartH}, state)
	end)
	
	-- Painter Background
	
	self.painterBackground1 = Painter(function(rect, state)
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.fillRect(0, 0, 400, 240)
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.setDitherPattern(0.4, playdate.graphics.image.kDitherTypeDiagonalLine)
		playdate.graphics.fillRect(0, 0, 400, 240)
	end)
	
	self.painterBackground2 = Painter(function(rect, state)
		-- background - right hill
		self.images.backgroundImage3:drawFaded(0, -10, 0.4, playdate.graphics.image.kDitherTypeBayer8x8)
	end)
	
	self.painterBackground3 = Painter(function(rect, state)
		-- background - flashing lights
		if state.tick == 0 then
			self.images.backgroundImage2:drawFaded(5, 0, 0.6, playdate.graphics.image.kDitherTypeDiagonalLine)
		else
			self.images.backgroundImage2:invertedImage():drawFaded(5, 0, 0.3, playdate.graphics.image.kDitherTypeDiagonalLine)
		end
	end)
	
	self.painterBackground4 = Painter(function(rect, state)
		-- background - left hill
		self.images.backgroundImage4:drawFaded(-20, 120, 0.9, playdate.graphics.image.kDitherTypeBayer4x4)
	end)
	
	self.painterBackgroundAssets = Painter(function(rect, state)
		-- background assets (coin, platforms, kill-block)
		self.images.backgroundImage:draw(200,30)
	end)
	
	-- Painter Text
	
	local painterTitleRectangleOutline = Painter(function(rect, state)
		-- title rectangle outline
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.fillRect(0, 0, rect.w, rect.h)
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.setDitherPattern(0.3, playdate.graphics.image.kDitherTypeDiagonalLine)
		playdate.graphics.fillRect(0, 0, rect.w, rect.h)
	end)
	
	local painterTitleRectangleFill = Painter(function(rect, state)
		-- title rectangle fill
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.setDitherPattern(0.3, playdate.graphics.image.kDitherTypeDiagonalLine)
		playdate.graphics.fillRect(0, 0, rect.w, rect.h)
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
		self.images.imagetable:getImage((state.index % 36) + 1):scaledImage(2):draw(10, -70)
		
		self.images.wheelImageTable:getImage((-state.index % 12) + 1):draw(140, 0)
	end)
end

function WidgetTitle:animate(animation)
	self:_animate(animation)
end

function WidgetTitle:_animate(animation)
	if animation == WidgetLevelSelect.kAnimations.animateIn then
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
		
		
	elseif animation == WidgetLevelSelect.kAnimations.animateBackIn then
		self.animators.animatorOut = playdate.graphics.animator.new(
			800, 
			math.min(240, self.animators.animatorOut:currentValue()), 
			0, 
			playdate.easingFunctions.outExpo, 
			200
		)
		self.animators.animatorOutWheel = playdate.graphics.animator.new(0, playdate.geometry.point.new(0, 0), playdate.geometry.point.new(0, 0), playdate.easingFunctions.outCirc, 0)
		self.animators.animatorWheel:reset()
	elseif animation == WidgetLevelSelect.kAnimations.animateOut then
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
	end
end

function WidgetTitle:_draw(rect)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.setDitherPattern(0.1, playdate.graphics.image.kDitherTypeBayer4x4)
	playdate.graphics.fillRect(0, 0, rect.w, rect.h)
	
	local animationValue = self.animators.animator1:currentValue() + self.animators.animatorOut:currentValue()
	
	self.painterBackground1:draw(Rect.offset(rect, 0, -20 - animationValue))
	self.painterBackground2:draw(Rect.offset(rect, animationValue, -20))
	self.painterBackground3:draw(Rect.offset(rect, 0, -20 - animationValue), { tick = self.tick })
	self.painterBackground4:draw(Rect.offset(rect, -animationValue, -20))
	self.painterBackgroundAssets:draw(Rect.offset(rect, animationValue, -20))
	
	local animationWheelValue = self.animators.animatorWheel:currentValue():offsetBy(self.animators.animatorOutWheel:currentValue().x, self.animators.animatorOutWheel:currentValue().y)
	self.painters.painterWheel:draw({x = animationWheelValue.x - 60, y = 30 + animationWheelValue.y, w = 280, h = 120}, { index = self.index % 36 })
	
	self.painters.painterTitle:draw({x = 0, y = 130 + self.animators.animator2:currentValue() + self.animators.animatorOut:currentValue(), w = 400, h = 57})
	self.painters.painterButton:draw({x = 115, y = 200 + self.animators.animator3:currentValue() + self.animators.animatorOut:currentValue(), w = 160, h = 27}, { tick = self.tick })
end

function WidgetTitle:_update()
	self.index += 2
	
	if self.index % 40 > 32 then
		self.tick = self.tick == 0 and 1 or 0
	end
end

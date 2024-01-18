import "utils/rect"
import "utils/position"

local gfx <const> = playdate.graphics
local easing <const> = playdate.easingFunctions
local geo <const> = playdate.geometry
local disp <const> = playdate.display

local _assign <const> = geo.rect.assign
local _tOffset <const> = geo.rect.tOffset
local _tSet <const> = geo.rect.tSet
local _tCenter <const> = geo.rect.tCenter

class("WidgetTitle").extends(Widget)

function WidgetTitle:init()
	self:supply(Widget.deps.animations)
	self:supply(Widget.deps.frame)
	
	self:setFrame(disp.getRect())
	
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
	self.imagetables.particles = gfx.imagetable.new(kAssetsImages.particles)
	self.imagetables.wheel = gfx.imagetable.new(kAssetsImages.wheel):scaled(2)
	self.images.backgroundImage = gfx.image.new(kAssetsImages.background)
	self.images.backgroundImage2 = gfx.image.new(kAssetsImages.background2)
	self.images.backgroundImage3 = gfx.image.new(kAssetsImages.background3)
	self.images.backgroundImage4 = gfx.image.new(kAssetsImages.background4)
	self.images.textImage = gfx.imageWithText("WHEEL RUNNER", 400, 100):scaledImage(3)
	self.images.pressStart = gfx.imageWithText("PRESS A", 200, 60):scaledImage(2)
	
	-- Painter Button
	
	local painterButtonFill = Painter(function(rect, state)
		if state.tick == 0 then
			-- press a button fill
			gfx.setColor(gfx.kColorWhite)
			gfx.setDitherPattern(0.8, gfx.image.kDitherTypeDiagonalLine)
			gfx.fillRoundRect(rect.x, rect.y, rect.w, rect.h, 6)
		else
			-- press a button fill
			gfx.setColor(gfx.kColorWhite)
			gfx.setDitherPattern(0.2, gfx.image.kDitherTypeDiagonalLine)
			gfx.fillRoundRect(rect.x, rect.y, rect.w, rect.h, 6)
		end
	end)
	
	local painterButtonOutline = Painter(function(rect, state)
		if state.tick == 0 then
			-- press a button outline
			gfx.setColor(gfx.kColorBlack)
			gfx.setDitherPattern(0.2, gfx.image.kDitherTypeDiagonalLine)
			gfx.setLineWidth(3)
			gfx.drawRoundRect(rect.x, rect.y, rect.w, rect.h, 6)
		else
			-- press a button outline
			gfx.setColor(gfx.kColorBlack)
			gfx.setLineWidth(3)
			gfx.drawRoundRect(rect.x, rect.y, rect.w, rect.h, 6)
		end
	end)
	
	local painterButtonPressStart = Painter(function(rect, state)
		if state.tick == 0 then
			-- press a text
			self.images.pressStart:drawFaded(rect.x, rect.y, 0.3, gfx.image.kDitherTypeDiagonalLine)
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
	end)
	
	-- Painter Background
	
	self.painterBackground1 = Painter(function(rect, state)
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRect(rect.x, rect.y, rect.w, rect.h)
		gfx.setColor(gfx.kColorBlack)
		gfx.setDitherPattern(0.4, gfx.image.kDitherTypeDiagonalLine)
		gfx.fillRect(rect.x, rect.y, rect.w, rect.h)
	end)
	
	self.painterBackground2 = Painter(function(rect, state)
		-- background - right hill
		local offsetRect = Rect.offset(rect, 0, -10)
		self.images.backgroundImage3:drawFaded(offsetRect.x, offsetRect.y, 0.4, gfx.image.kDitherTypeBayer8x8)
	end)
	
	self.painterBackground3 = Painter(function(rect, state)
		local offsetRect = Rect.offset(rect, 5, 0)
		-- background - flashing lights
		if state.tick == 0 then
			self.images.backgroundImage2:drawFaded(offsetRect.x, offsetRect.y, 0.6, gfx.image.kDitherTypeDiagonalLine)
		else
			self.images.backgroundImage2:invertedImage():drawFaded(offsetRect.x, offsetRect.y, 0.3, gfx.image.kDitherTypeDiagonalLine)
		end
	end)
	
	self.painterBackground4 = Painter(function(rect, state)
		local offsetRect = Rect.offset(rect, -20, 120)
		-- background - left hill
		self.images.backgroundImage4:drawFaded(offsetRect.x, offsetRect.y, 0.9, gfx.image.kDitherTypeBayer4x4)
	end)
	
	self.painterBackgroundAssets = Painter(function(rect, state)
		local offsetRect = Rect.offset(rect, 200, 30)
		-- background assets (coin, platforms, kill-block)
		self.images.backgroundImage:draw(offsetRect.x, offsetRect.y)
	end)
	
	-- Painter Text
	
	local painterTitleRectangleOutline = Painter(function(rect, state)
		-- title rectangle outline
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRect(0, 0, rect.w, rect.h)
		gfx.setColor(gfx.kColorBlack)
		gfx.setDitherPattern(0.3, gfx.image.kDitherTypeDiagonalLine)
		gfx.fillRect(rect.x, rect.y, rect.w, rect.h)
	end)
	
	local painterTitleRectangleFill = Painter(function(rect, state)
		-- title rectangle fill
		gfx.setColor(gfx.kColorWhite)
		gfx.setDitherPattern(0.3, gfx.image.kDitherTypeDiagonalLine)
		gfx.fillRect(rect.x, rect.y, rect.w, rect.h)
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
	end)
end

function WidgetTitle:_animate(animation, queueFinishedCallback)
	if animation == self.kAnimations.onFirstOpen then
		self.animators.animator1 = gfx.animator.new(800, 240, 0, easing.outExpo, 100)
		self.animators.animator2 = gfx.animator.new(800, 150, 0, easing.outExpo, 500)
		self.animators.animator3 = gfx.animator.new(800, 150, 0, easing.outCirc, 1000)
		self.animators.animatorWheel = gfx.animator.new(
			800, 
			geo.point.new(-200, -30), 
			geo.point.new(0, 0), 
			easing.outQuad, 
			800
		)
		
		queueFinishedCallback(1800)
	elseif animation == self.kAnimations.fromLevelSelect then
		self.animators.animatorOut = gfx.animator.new(
			800, 
			math.min(240, self.animators.animatorOut:currentValue()), 
			0, 
			easing.outExpo, 
			200
		)
		self.animators.animatorOutWheel = gfx.animator.new(0, geo.point.new(0, 0), geo.point.new(0, 0), easing.outCirc, 0)
		self.animators.animatorWheel:reset()
		
		queueFinishedCallback(1000)
	elseif animation == self.kAnimations.toLevelSelect then
		local animatorValue = self:getAnimatorValue(self.animators.animatorOut)
		self.animators.animatorOut = gfx.animator.new(
			800, 
			math.max(0, animatorValue), 
			240, 
			easing.inExpo, 200
		)
		self.animators.animatorOutWheel = gfx.animator.new(
			800, 
			geo.point.new(0, 0), 
			geo.point.new(450, 100),  
			easing.inQuad, 
			500
		)
		
		queueFinishedCallback(1300)
	end
end

function WidgetTitle:_draw(rect)
	
	local frame = self.frame
	local _rects = self.rects
	
	-- Warning: This is a Work-around! What should really happen is: 
	-- 1) in _animate, toggle :setVisible to true.
	-- 2) setting visible should only take effect NEXT frame, not current frame. and 
	-- 3) draw happens once a full round of update() has been called, performing the layout as needed.
	-- ... But for now, we just check if the layout has been performed by checking this rect.
	if _rects.top == nil then
		return
	end
	self.painterBackground1:draw(_rects.top)
	self.painterBackground2:draw(_rects.right)
	self.painterBackground3:draw(_rects.top, { tick = self.tick })
	self.painterBackground4:draw(_rects.left)
	self.painterBackgroundAssets:draw(_rects.right)
	
	self.painters.painterWheel:draw(_rects.wheel, { index = self.index % 36 })
	self.painters.painterTitle:draw(_rects.title)
	
	self.painters.painterButton:draw(_rects.button, { tick = self.tick })
end

function WidgetTitle:_update()
	self.index += 2
	
	local tickPrevious = self.tick
	if self.index % 40 > 32 then
		self.tick = self.tick == 0 and 1 or 0
	end
	
	if self.tick ~= tickPrevious then
		gfx.sprite.addDirtyRect(0, 0, 400, 240)
	end
	
	self.painters.painterWheel:markDirty()
	self.painters.painterButton:markDirty()
	
	if self:isAnimating() == true then
		gfx.sprite.addDirtyRect(0, 0, 400, 240)
		
		-- animation update: perform layout
		
		local _animators = self.animators
		local _rects = self.rects
		local frame = self.frame
		local _getAnimatorValue = self.getAnimatorValue
		
		local animatorValueBackground = _getAnimatorValue(self, _animators.animator1, _animators.animatorOut)
		local animatorValueWheel = _getAnimatorValue(self, _animators.animatorWheel, _animators.animatorOutWheel)
		local animatorValueTitle =  _getAnimatorValue(self, _animators.animator2, _animators.animatorOut)
		local animatorValueButton =  _getAnimatorValue(self, _animators.animator2, _animators.animatorOut)
		
		_rects.top = _tOffset(_assign(_rects.top, frame), 0, -20 - animatorValueBackground)
		_rects.left = _tOffset(_assign(_rects.left, frame), -animatorValueBackground, -20)
		_rects.right = _tOffset(_assign(_rects.right, frame), animatorValueBackground, -20)
		_rects.wheel = _assign(_rects.wheel, animatorValueWheel.x - 60, 30 + animatorValueWheel.y, 280, 120)
		_rects.title = _tSet(_tOffset(_assign(_rects.title, frame), 0, 130 + animatorValueTitle), nil, nil, nil, 57)
		_rects.button = _tOffset(_tSet(_tCenter(_assign(_rects.button, 0, 0, 160, 27), frame), nil, 200), 0, animatorValueButton)
	end
end

function WidgetTitle:_unload()
	self.imagetables = nil
	self.images = nil
	self.painters = nil
	self.animators = nil
end
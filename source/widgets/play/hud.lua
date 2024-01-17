import "utils/time"
import "utils/textPainter"

local gfx <const> = playdate.graphics
local easing <const> = playdate.easingFunctions

class("WidgetHUD").extends(Widget)

function WidgetHUD:init()
	self:supply(Widget.deps.state)
	self:supply(Widget.deps.animators)
	self:setStateInitial({onScreen = 1, offScreen = 2}, 1)
	
	self.images = {}
	self.painters = {}
	
	self.data = {}
	
	self.textPainter = textPainter({
		charsPreloaded = "1234567890.:", 
		scale = 2,
		spacing = 4
	})
end

function WidgetHUD:_load()
	self.images.coin = gfx.image.new(kAssetsImages.coin)
	
	self.painters.frame = Painter(function(rect)
		gfx.setColor(gfx.kColorBlack)
		gfx.setLineWidth(2)
		gfx.drawRoundRect(rect.x, rect.y, rect.w, rect.h, 6)
		gfx.setColor(gfx.kColorWhite)
		gfx.setDitherPattern(0.25, gfx.image.kDitherTypeDiagonalLine)
		gfx.setLineWidth(1)
		
		local insetRect = Rect.inset(rect, 2, 2)
		gfx.fillRoundRect(insetRect.x, insetRect.y, insetRect.w, insetRect.h, 6)
	end)
	
	self.data.time = 0
	self.data.coins = 0
	self.data.timeLabelText = ""
	self.data.coinsLabelText = ""
end

function WidgetHUD:_draw(frame)
	local animatorValue = self:getAnimatorValue(self.animators.hideAnimator)
	local offsetRect = Rect.offset(frame, 0, animatorValue)
	self.painters.frame:draw(offsetRect)
	
	self.textPainter:drawText(self.data.timeLabelText, offsetRect.x + 10, offsetRect.y + 7)
	
	local coinImageSize = self.images.coin:getSize()
	self.textPainter:drawTextAlignedRight(self.data.coinsLabelText, offsetRect.x + offsetRect.w - 10 - coinImageSize, offsetRect.y + 7)
	
	self.images.coin:draw(offsetRect.x + offsetRect.w - 10 - coinImageSize, offsetRect.y + 3)
	
	self.frame = frame
end

function WidgetHUD:_update()
	local timeLabelTextPrevious = self.data.timeLabelText
	self.data.timeLabelText = convertToTimeString(self.data.time, 2)
	
	local coinsLabelTextPrevious = self.data.coinsLabelText
	self.data.coinsLabelText = ""..self.data.coins
	
	if self.frame ~= nil then
		if self:isAnimating() == true then
			gfx.sprite.addDirtyRect(0, 0, self.frame.x + self.frame.w, self.frame.y + self.frame.h)
		else	
			local labelWidth = 150
			
			if self.data.coinsLabelText ~= coinsLabelTextPrevious then
				gfx.sprite.addDirtyRect(self.frame.x + self.frame.w - labelWidth - 10, self.frame.y, labelWidth, self.frame.h)
			end
			
			if self.data.timeLabelText ~= timeLabelTextPrevious then
				gfx.sprite.addDirtyRect(self.frame.x + 10, self.frame.y, labelWidth, self.frame.h)
			end
		end
	end
end

function WidgetHUD:_changeState(stateFrom, stateTo)
	if stateFrom == self.kStates.offScreen and (stateTo == self.kStates.onScreen) then
		self.animators.hideAnimator = gfx.animator.new(400, -200, 0, easing.outQuint)
	elseif stateFrom == self.kStates.onScreen and (stateTo == self.kStates.offScreen) then
		self.animators.hideAnimator = gfx.animator.new(400, 0, -200, easing.inQuint)
	end
end

function WidgetHUD:_unload()	
	self.images = nil
	self.animators = nil
	self.painters = nil
end
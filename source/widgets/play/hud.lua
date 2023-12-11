import "utils/time"
import "utils/textPainter"

class("WidgetHUD").extends(Widget)

function WidgetHUD:init()
	self:supply(Widget.kDeps.state)
	self:setStateInitial({onScreen = 1, offScreen = 2})
	
	self.images = {}
	self.painters = {}
	
	self.data = {}
	self.animators = {}
	
	self.textPainter = textPainter({
		charsPreloaded = "1234567890.:", 
		scale = 2,
		spacing = 4
	})
end

function WidgetHUD:_load()
	self.images.coin = playdate.graphics.image.new(kAssetsImages.coin)
	
	self.painters.frame = Painter(function(rect)
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.setLineWidth(2)
		playdate.graphics.drawRoundRect(rect.x, rect.y, rect.w, rect.h, 6)
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.setDitherPattern(0.25, playdate.graphics.image.kDitherTypeDiagonalLine)
		playdate.graphics.setLineWidth(1)
		
		local insetRect = Rect.inset(rect, 2, 2)
		playdate.graphics.fillRoundRect(insetRect.x, insetRect.y, insetRect.w, insetRect.h, 6)
	end)
	
	self.data.time = 0
	self.data.coins = 0
	
	self.animators.hideAnimator = playdate.graphics.animator.new(0, 0, 0)
end

function WidgetHUD:_draw(rect)
	local offsetRect = Rect.offset(rect, 0, self.animators.hideAnimator:currentValue())
	self.painters.frame:draw(offsetRect)
	
	self.textPainter:drawText(self.data.timeLabelText, offsetRect.x + 10, offsetRect.y + 7)
	
	local coinImageSize = self.images.coin:getSize()
	self.textPainter:drawTextAlignedRight(self.data.coinsLabelText, offsetRect.x + offsetRect.w - 10 - coinImageSize, offsetRect.y + 7)
	
	self.images.coin:draw(offsetRect.x + offsetRect.w - 10 - coinImageSize, offsetRect.y + 3)
end

function WidgetHUD:_update()
	self.data.timeLabelText = convertToTimeString(self.data.time, 2)
	self.data.coinsLabelText = ""..self.data.coins
end

function WidgetHUD:changeState(stateFrom, stateTo)
	if stateFrom == self.kStates.offScreen and (stateTo == self.kStates.onScreen) then
		self.animators.hideAnimator = playdate.graphics.animator.new(400, -200, 0, playdate.easingFunctions.outQuint)
	elseif stateFrom == self.kStates.onScreen and (stateTo == self.kStates.offScreen) then
		self.animators.hideAnimator = playdate.graphics.animator.new(400, 0, -200, playdate.easingFunctions.inQuint)
	end
end
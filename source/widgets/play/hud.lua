import "utils/time"
import "utils/textPainter"

local gfx <const> = playdate.graphics
local easing <const> = playdate.easingFunctions
local geo <const> = playdate.geometry

local _assign <const> = geo.rect.assign
local _tOffset <const> = geo.rect.tOffset

class("WidgetHUD").extends(Widget)

function WidgetHUD:init()
	self:supply(Widget.deps.state)
	self:supply(Widget.deps.animators)
	self:supply(Widget.deps.frame)
		
	self:setStateInitial({onScreen = 1, offScreen = 2}, 2)
	
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

function WidgetHUD:_draw(frame, rect)
	local _rects = self.rects
	-- TODO: Same warning as WidgetTitle
	if _rects.frame == nil then
		return
	end
	
	self.painters.frame:draw(_rects.frame)
	self.textPainter:drawText(self.data.timeLabelText, _rects.timeText.x, _rects.timeText.y)
	self.textPainter:drawTextAlignedRight(self.data.coinsLabelText, _rects.coinsText.x, _rects.coinsText.y)
	self.images.coin:draw(_rects.coinImage.x, _rects.coinImage.y)
end

function WidgetHUD:_update()
	local timeLabelTextPrevious = self.data.timeLabelText
	--self.data.timeLabelText = convertToTimeString(self.data.time, 2)
	
	local coinsLabelTextPrevious = self.data.coinsLabelText
	self.data.coinsLabelText = ""..self.data.coins
	
	if self:isAnimating() == true then
		local animatorValue = self:getAnimatorValue(self.animators.hideAnimator)
		local coinImageSize = self.images.coin:getSize()
		local _rects = self.rects
		local _frame = self.frame
		_rects.frame = _tOffset(_assign(_rects.frame, _frame), 0, animatorValue)
		_rects.timeText = _tOffset(_assign(_rects.timeText, _rects.frame), 10, 7)
		_rects.coinsText = _tOffset(_assign(_rects.coinsText, _rects.frame), _rects.frame.w - 10 - coinImageSize, 7)
		_rects.coinImage = _tOffset(_assign(_rects.coinImage, _rects.frame), _rects.frame.w - 10 - coinImageSize, 3)
		
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
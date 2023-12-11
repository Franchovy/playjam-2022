class("WidgetTransition").extends(Widget)

function WidgetTransition:init()
	self:supply(Widget.kDeps.state)
	
	self:createSprite(kZIndex.transition)
	
	self:setStateInitial({ outside = 1, inside = 2 }, 1)
	
	self.painters = {}
	self.animators = {}
end

function WidgetTransition:_load()
	self.painters.screen = Painter(function(rect)
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.fillRect(rect.x, rect.y, rect.w, rect.h)
	end)
	
	self.animators.animator = playdate.graphics.animator.new(0, 0, 0)
end

function WidgetTransition:_draw(rect)
	local animatorValue = self.animators.animator:currentValue()
	self.painters.screen:draw(Rect.offset(rect, animatorValue, 0))
end

function WidgetTransition:_update()
	
end

function WidgetTransition:changeState(stateFrom, stateTo)
	if stateFrom == self.kStates.outside and stateTo == self.kStates.inside then
		self.animators.animator = playdate.graphics.animator.new(600, -400, 0, playdate.easingFunctions.outBounce)
	end
	
	if stateFrom == self.kStates.inside and stateTo == self.kStates.outside then
		self.animators.animator = playdate.graphics.animator.new(600, 0, -400, playdate.easingFunctions.inQuint)
	end
end